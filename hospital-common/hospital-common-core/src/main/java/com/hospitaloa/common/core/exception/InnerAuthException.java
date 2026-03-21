package com.hospitaloa.common.core.exception;

/**
 * 内部认证异常
 * 
 * @author hospital-oa-system
 */
public class InnerAuthException extends RuntimeException
{
    private static final long serialVersionUID = 1L;

    public InnerAuthException(String message)
    {
        super(message);
    }
}
