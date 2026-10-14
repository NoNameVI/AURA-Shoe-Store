package com.aura.store.validation;

import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.InitBinder;

/** Chuan hoa chuoi nhap tu form truoc khi Bean Validation kiem tra. */
@ControllerAdvice
public class FormInputBindingAdvice {

    /** Cat khoang trang va doi chuoi rong thanh null cho cac form MVC. */
    @InitBinder
    public void trimFormStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }
}
