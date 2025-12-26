// External Validation Library for East Gojjam VIMS
class FormValidator {
    constructor() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }

    init() {
        try {
            this.addValidationStyles();
            this.setupValidation();
        } catch (error) {
            console.error('Validation initialization error:', error);
        }
    }

    addValidationStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .validation-error { border: 2px solid #dc3545 !important; box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1) !important; }
            .validation-success { border: 2px solid #28a745 !important; box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.1) !important; }
            .error-message { color: #dc3545; font-size: 0.875rem; margin-top: 0.25rem; display: block; }
            .success-message { color: #28a745; font-size: 0.875rem; margin-top: 0.25rem; display: block; }
        `;
        document.head.appendChild(style);
    }

    setupValidation() {
        try {
            const forms = document.querySelectorAll('form');
            if (forms.length === 0) return;
            
            forms.forEach(form => {
                if (form) this.validateForm(form);
            });
        } catch (error) {
            console.error('Setup validation error:', error);
        }
    }

    validateForm(form) {
        try {
            const inputs = form.querySelectorAll('input, select, textarea');
            
            inputs.forEach(input => {
                if (input) {
                    input.addEventListener('blur', () => this.validateField(input));
                    input.addEventListener('input', () => this.clearErrors(input));
                }
            });

            form.addEventListener('submit', (e) => {
                if (!this.validateAllFields(form)) {
                    e.preventDefault();
                    this.showFormErrors(form);
                }
            });
        } catch (error) {
            console.error('Validate form error:', error);
        }
    }

    validateField(field) {
        const value = field.value.trim();
        const fieldName = field.name || field.id;
        let isValid = true;
        let errorMessage = '';

        this.clearErrors(field);

        if (field.hasAttribute('required') && !value) {
            isValid = false;
            errorMessage = `${this.getFieldLabel(field)} is required`;
        }

        if (value && isValid) {
            switch (field.type) {
                case 'email':
                    if (!this.isValidEmail(value)) {
                        isValid = false;
                        errorMessage = 'Please enter a valid email address';
                    }
                    break;
                case 'tel':
                    if (!this.isValidPhone(value)) {
                        isValid = false;
                        errorMessage = 'Please enter a valid phone number';
                    }
                    break;
                case 'date':
                    if (!this.isValidDate(value, field)) {
                        isValid = false;
                        errorMessage = this.getDateErrorMessage(field);
                    }
                    break;
            }

            if ((fieldName.includes('name') || fieldName.includes('full_name')) && !this.isValidName(value)) {
                isValid = false;
                errorMessage = 'Name should contain only letters and spaces';
            }

            if (['woreda', 'kebele', 'village'].includes(fieldName) && !this.isValidLocation(value)) {
                isValid = false;
                errorMessage = 'Location should contain only letters, numbers, and spaces';
            }

            // Age at death validation
            if (fieldName === 'age_at_death' && !this.isValidAgeAtDeath(value)) {
                isValid = false;
                errorMessage = 'Age at death must be 0 or greater';
            }
        }

        if (isValid) {
            this.showSuccess(field);
        } else {
            this.showError(field, errorMessage);
        }

        return isValid;
    }

    validateAllFields(form) {
        const fields = form.querySelectorAll('input, select, textarea');
        let allValid = true;

        fields.forEach(field => {
            if (!this.validateField(field)) {
                allValid = false;
            }
        });

        return allValid;
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    isValidPhone(phone) {
        const phoneRegex = /^[\+]?[0-9\-\(\)\s]{10,}$/;
        return phoneRegex.test(phone);
    }

    isValidName(name) {
        const nameRegex = /^[a-zA-Z\s]+$/;
        return nameRegex.test(name);
    }

    isValidLocation(location) {
        const locationRegex = /^[a-zA-Z0-9\s]+$/;
        return locationRegex.test(location);
    }

    isValidDate(dateStr, field) {
        const date = new Date(dateStr);
        const today = new Date();
        
        if (isNaN(date.getTime())) return false;

        if (field.name === 'date_of_birth') {
            return date <= today && date >= new Date('1900-01-01');
        }

        if (field.name === 'date_of_death') {
            if (date > today || date < new Date('1900-01-01')) return false;
            
            // Check death date is not before birth date
            const birthDateField = document.querySelector('input[name="date_of_birth"]');
            if (birthDateField && birthDateField.value) {
                const birthDate = new Date(birthDateField.value);
                if (date < birthDate) {
                    return false;
                }
                // Auto-calculate age at death if field exists
                this.calculateAgeAtDeath(birthDate, date);
            }
            return true;
        }

        if (field.name === 'registration_date') {
            const oneYearAgo = new Date();
            oneYearAgo.setFullYear(today.getFullYear() - 1);
            return date <= today && date >= oneYearAgo;
        }

        return date <= today;
    }

    getDateErrorMessage(field) {
        if (field.name === 'date_of_birth') {
            return 'Birth date must be valid and not in the future';
        }
        if (field.name === 'date_of_death') {
            const birthDateField = document.querySelector('input[name="date_of_birth"]');
            if (birthDateField && birthDateField.value) {
                const birthDate = new Date(birthDateField.value);
                const deathDate = new Date(field.value);
                if (deathDate < birthDate) {
                    return 'Death date cannot be before birth date';
                }
            }
            return 'Death date must be valid and not in the future';
        }
        if (field.name === 'registration_date') {
            return 'Registration date must be within the last year';
        }
        return 'Please enter a valid date';
    }

    getFieldLabel(field) {
        try {
            const formGroup = field.closest('.form-group');
            if (formGroup) {
                const label = formGroup.querySelector('label');
                if (label && label.textContent) {
                    return label.textContent.replace(':', '');
                }
            }
            return field.name || field.id || 'Field';
        } catch (error) {
            return field.name || 'Field';
        }
    }

    showError(field, message) {
        try {
            field.classList.remove('validation-success');
            field.classList.add('validation-error');
            
            this.removeMessage(field);
            
            const errorDiv = document.createElement('span');
            errorDiv.className = 'error-message';
            errorDiv.textContent = message;
            
            if (field.parentNode) {
                field.parentNode.appendChild(errorDiv);
            }
        } catch (error) {
            console.error('Show error message failed:', error);
        }
    }

    showSuccess(field) {
        try {
            field.classList.remove('validation-error');
            field.classList.add('validation-success');
            
            this.removeMessage(field);
            
            const successDiv = document.createElement('span');
            successDiv.className = 'success-message';
            successDiv.textContent = '✓ Valid';
            
            if (field.parentNode) {
                field.parentNode.appendChild(successDiv);
            }
        } catch (error) {
            console.error('Show success message failed:', error);
        }
    }

    clearErrors(field) {
        field.classList.remove('validation-error', 'validation-success');
        this.removeMessage(field);
    }

    removeMessage(field) {
        try {
            if (field.parentNode) {
                const existingMessage = field.parentNode.querySelector('.error-message, .success-message');
                if (existingMessage) {
                    existingMessage.remove();
                }
            }
        } catch (error) {
            console.error('Remove message failed:', error);
        }
    }

    isValidAgeAtDeath(age) {
        const ageNum = parseInt(age);
        return !isNaN(ageNum) && ageNum >= 0 && ageNum <= 150;
    }

    calculateAgeAtDeath(birthDate, deathDate) {
        const ageField = document.querySelector('input[name="age_at_death"]');
        if (ageField && !ageField.value) {
            const age = deathDate.getFullYear() - birthDate.getFullYear();
            const monthDiff = deathDate.getMonth() - birthDate.getMonth();
            const dayDiff = deathDate.getDate() - birthDate.getDate();
            
            let finalAge = age;
            if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
                finalAge--;
            }
            
            if (finalAge >= 0) {
                ageField.value = finalAge;
            }
        }
    }

    showFormErrors(form) {
        const firstError = form.querySelector('.validation-error');
        if (firstError) {
            firstError.focus();
            firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }
}

// Initialize validator safely
try {
    const validator = new FormValidator();
} catch (error) {
    console.error('Failed to initialize form validator:', error);
}