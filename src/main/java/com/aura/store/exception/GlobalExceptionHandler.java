package com.aura.store.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

/**
 * Converts application exceptions into shared Thymeleaf error pages.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /** Tra trang 404 khi tai nguyen khong ton tai hoac khong duoc phep xem. */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ModelAndView handleNotFound(
            ResourceNotFoundException exception,
            HttpServletRequest request
    ) {
        return errorView(HttpStatus.NOT_FOUND, exception.getMessage(), request);
    }

    /** Tra trang 400 cho loi nghiep vu du kien truoc. */
    @ExceptionHandler(BusinessException.class)
    public ModelAndView handleBusinessException(
            BusinessException exception,
            HttpServletRequest request
    ) {
        return errorView(HttpStatus.BAD_REQUEST, exception.getMessage(), request);
    }

    /** Giu dung ma 403 khi method security tu choi quyen catalog. */
    @ExceptionHandler(AccessDeniedException.class)
    public ModelAndView handleAccessDenied(
            AccessDeniedException exception,
            HttpServletRequest request
    ) {
        return errorView(HttpStatus.FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.", request);
    }

    /** Tra 409 neu mot giao dich dong thoi vi pham UNIQUE hoac khoa ngoai. */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ModelAndView handleDataConflict(
            DataIntegrityViolationException exception,
            HttpServletRequest request
    ) {
        return errorView(HttpStatus.CONFLICT,
                "Dữ liệu đã tồn tại hoặc đang được sử dụng.", request);
    }

    /** Che thong tin noi bo khi he thong gap loi khong mong muon. */
    @ExceptionHandler(Exception.class)
    public ModelAndView handleUnexpectedException(
            Exception exception,
            HttpServletRequest request
    ) {
        return errorView(HttpStatus.INTERNAL_SERVER_ERROR,
                "Đã xảy ra lỗi không mong muốn.", request);
    }

    /** Dung chung mot view loi voi ma HTTP phu hop. */
    private ModelAndView errorView(
            HttpStatus status,
            String message,
            HttpServletRequest request
    ) {
        ModelAndView modelAndView = new ModelAndView("error/error");
        modelAndView.setStatus(status);
        modelAndView.addObject("status", status.value());
        modelAndView.addObject("error", status.getReasonPhrase());
        modelAndView.addObject("message", message);
        modelAndView.addObject("path", request.getRequestURI());
        return modelAndView;
    }
}
