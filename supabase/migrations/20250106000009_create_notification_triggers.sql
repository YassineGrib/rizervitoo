-- Notification triggers for automatic notification generation

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_title TEXT,
  p_message TEXT,
  p_type TEXT DEFAULT 'system',
  p_priority TEXT DEFAULT 'medium',
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  notification_id UUID;
BEGIN
  INSERT INTO public.notifications (
    user_id,
    title,
    message,
    type,
    priority,
    expires_at
  ) VALUES (
    p_user_id,
    p_title,
    p_message,
    p_type,
    p_priority,
    p_expires_at
  ) RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to notify booking creation
CREATE OR REPLACE FUNCTION notify_booking_created()
RETURNS TRIGGER AS $$
DECLARE
  guest_name TEXT;
  accommodation_title TEXT;
  host_id UUID;
BEGIN
  -- Get guest name
  SELECT full_name INTO guest_name
  FROM public.profiles
  WHERE id = NEW.guest_id;
  
  -- Get accommodation details and host
  SELECT title, owner_id INTO accommodation_title, host_id
  FROM public.accommodations
  WHERE id = NEW.accommodation_id;
  
  -- Notify guest about booking creation
  PERFORM create_notification(
    NEW.guest_id,
    'تم إنشاء حجز جديد',
    'تم إنشاء حجزك في ' || accommodation_title || ' بنجاح. سيتم مراجعته قريباً.',
    'booking',
    'high'
  );
  
  -- Notify host about new booking
  PERFORM create_notification(
    host_id,
    'حجز جديد',
    'لديك حجز جديد من ' || guest_name || ' في ' || accommodation_title || '.',
    'booking',
    'high'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to notify booking status change
CREATE OR REPLACE FUNCTION notify_booking_status_changed()
RETURNS TRIGGER AS $$
DECLARE
  guest_name TEXT;
  accommodation_title TEXT;
  host_id UUID;
  status_message TEXT;
BEGIN
  -- Only proceed if status actually changed
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;
  
  -- Get guest name
  SELECT full_name INTO guest_name
  FROM public.profiles
  WHERE id = NEW.guest_id;
  
  -- Get accommodation details and host
  SELECT title, owner_id INTO accommodation_title, host_id
  FROM public.accommodations
  WHERE id = NEW.accommodation_id;
  
  -- Set status message based on new status
  CASE NEW.status
    WHEN 'confirmed' THEN
      status_message := 'تم تأكيد حجزك في ' || accommodation_title || '. استعد لرحلة رائعة!';
    WHEN 'cancelled' THEN
      status_message := 'تم إلغاء حجزك في ' || accommodation_title || '.';
    WHEN 'completed' THEN
      status_message := 'تم إكمال إقامتك في ' || accommodation_title || '. نتمنى أن تكون قد استمتعت!';
    ELSE
      status_message := 'تم تحديث حالة حجزك في ' || accommodation_title || ' إلى: ' || NEW.status;
  END CASE;
  
  -- Notify guest about status change
  PERFORM create_notification(
    NEW.guest_id,
    'تحديث حالة الحجز',
    status_message,
    'booking',
    CASE NEW.status
        WHEN 'confirmed' THEN 'high'
        WHEN 'cancelled' THEN 'high'
        WHEN 'completed' THEN 'normal'
        ELSE 'normal'
      END
  );
  
  -- Notify host about status change (except for completed bookings)
  IF NEW.status != 'completed' THEN
    PERFORM create_notification(
      host_id,
      'تحديث حالة الحجز',
      'تم تحديث حالة حجز ' || guest_name || ' في ' || accommodation_title || ' إلى: ' || NEW.status,
      'booking',
      'normal'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to notify payment status change
CREATE OR REPLACE FUNCTION notify_payment_status_changed()
RETURNS TRIGGER AS $$
DECLARE
  accommodation_title TEXT;
  payment_message TEXT;
BEGIN
  -- Only proceed if payment status actually changed
  IF OLD.payment_status = NEW.payment_status THEN
    RETURN NEW;
  END IF;
  
  -- Get accommodation title
  SELECT title INTO accommodation_title
  FROM public.accommodations
  WHERE id = NEW.accommodation_id;
  
  -- Set payment message based on new status
  CASE NEW.payment_status
    WHEN 'paid' THEN
      payment_message := 'تم استلام دفعتك لحجز ' || accommodation_title || ' بنجاح.';
    WHEN 'refunded' THEN
      payment_message := 'تم استرداد مبلغ حجز ' || accommodation_title || ' إلى حسابك.';
    ELSE
      payment_message := 'تم تحديث حالة الدفع لحجز ' || accommodation_title || ' إلى: ' || NEW.payment_status;
  END CASE;
  
  -- Notify guest about payment status change
  PERFORM create_notification(
    NEW.guest_id,
    'تحديث حالة الدفع',
    payment_message,
    'payment',
    CASE NEW.payment_status
        WHEN 'paid' THEN 'high'
        WHEN 'refunded' THEN 'high'
        ELSE 'normal'
      END
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to notify upcoming check-in (daily job)
CREATE OR REPLACE FUNCTION notify_upcoming_checkins()
RETURNS void AS $$
DECLARE
  booking_record RECORD;
  accommodation_title TEXT;
BEGIN
  -- Find bookings with check-in tomorrow
  FOR booking_record IN
    SELECT b.*, p.full_name as guest_name
    FROM public.bookings b
    JOIN public.profiles p ON b.guest_id = p.id
    WHERE b.check_in_date = CURRENT_DATE + INTERVAL '1 day'
      AND b.status = 'confirmed'
  LOOP
    -- Get accommodation title
    SELECT title INTO accommodation_title
    FROM public.accommodations
    WHERE id = booking_record.accommodation_id;
    
    -- Notify guest about upcoming check-in
    PERFORM create_notification(
      booking_record.guest_id,
      'تذكير: تسجيل الوصول غداً',
      'تذكير ودود: موعد تسجيل وصولك في ' || accommodation_title || ' غداً. استعد لرحلة رائعة!',
      'reminder',
      'normal',
      NOW() + INTERVAL '2 days'
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to notify expired bookings (daily job)
CREATE OR REPLACE FUNCTION notify_expired_bookings()
RETURNS void AS $$
DECLARE
  booking_record RECORD;
  accommodation_title TEXT;
BEGIN
  -- Find bookings that expired yesterday and are still pending
  FOR booking_record IN
    SELECT b.*
    FROM public.bookings b
    WHERE b.check_in_date = CURRENT_DATE - INTERVAL '1 day'
      AND b.status = 'pending'
  LOOP
    -- Get accommodation title
    SELECT title INTO accommodation_title
    FROM public.accommodations
    WHERE id = booking_record.accommodation_id;
    
    -- Notify guest about expired booking
    PERFORM create_notification(
      booking_record.guest_id,
      'انتهت صلاحية الحجز',
      'انتهت صلاحية حجزك في ' || accommodation_title || ' لعدم التأكيد في الوقت المحدد.',
      'system',
      'normal',
      NOW() + INTERVAL '7 days'
    );
    
    -- Update booking status to cancelled
    UPDATE public.bookings
    SET status = 'cancelled',
        cancellation_reason = 'انتهت صلاحية الحجز',
        cancelled_at = NOW()
    WHERE id = booking_record.id;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers
CREATE TRIGGER trigger_notify_booking_created
  AFTER INSERT ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION notify_booking_created();

CREATE TRIGGER trigger_notify_booking_status_changed
  AFTER UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION notify_booking_status_changed();

CREATE TRIGGER trigger_notify_payment_status_changed
  AFTER UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION notify_payment_status_changed();

-- Note: The following functions should be called by a scheduled job (cron job)
-- notify_upcoming_checkins() - should run daily
-- notify_expired_bookings() - should run daily

-- Example of how to set up scheduled jobs in Supabase:
-- SELECT cron.schedule('notify-upcoming-checkins', '0 9 * * *', 'SELECT notify_upcoming_checkins();');
-- SELECT cron.schedule('notify-expired-bookings', '0 10 * * *', 'SELECT notify_expired_bookings();');