// Typing Animation for Hero Title
document.addEventListener('DOMContentLoaded', function() {
    const heroTitle = document.getElementById('hero-title');
    if (!heroTitle) return;
    
    const originalText = 'اكتشف الجزائر مع RizerVitoo';
    let currentIndex = 0;
    
    // Clear the title initially
    heroTitle.textContent = '';
    
    // Add typing cursor
    heroTitle.classList.add('typing-animation');
    
    // Typing effect
    function typeWriter() {
        if (currentIndex < originalText.length) {
            heroTitle.textContent += originalText.charAt(currentIndex);
            currentIndex++;
            setTimeout(typeWriter, 100);
        } else {
            // Remove cursor after typing is complete
            setTimeout(() => {
                heroTitle.classList.remove('typing-animation');
            }, 1000);
        }
    }
    
    // Start typing animation after page load
    setTimeout(typeWriter, 1000);
    
    // Smooth scroll for download buttons
    const downloadBtn = document.querySelector('.download-btn');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Create ripple effect
            const ripple = document.createElement('span');
            ripple.classList.add('ripple');
            this.appendChild(ripple);
            
            // Remove ripple after animation
            setTimeout(() => {
                ripple.remove();
            }, 600);
            
            // Download the APK
            const link = document.createElement('a');
            link.href = this.href;
            link.download = 'rivervitoo.apk';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    }
    
    // Parallax effect for floating elements
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const floatingElements = document.querySelectorAll('.floating-circle');
        
        floatingElements.forEach((element, index) => {
            if (element) {
                const speed = 0.5 + (index * 0.2);
                element.style.transform = `translateY(${scrolled * speed}px) rotate(${scrolled * 0.1}deg)`;
            }
        });
    });
    
    // Intersection Observer for animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Observe feature cards and sections
    const elementsToObserve = document.querySelectorAll('.feature-card, .section');
    if (elementsToObserve.length > 0) {
        elementsToObserve.forEach(el => {
            observer.observe(el);
        });
    }
});

// Add CSS for ripple effect
const style = document.createElement('style');
style.textContent = `
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: ripple-animation 0.6s linear;
        pointer-events: none;
    }
    
    @keyframes ripple-animation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
    
    .download-btn {
        position: relative;
        overflow: hidden;
    }
    
    .animate-in {
        animation: slideInUp 0.6s ease-out;
    }
    
    @keyframes slideInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);