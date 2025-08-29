import styled, { keyframes } from 'styled-components';

// Keyframes untuk animasi
export const spin = keyframes`
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
`;

export const fadeIn = keyframes`
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
`;

export const shimmer = keyframes`
  0% { background-position: -200px 0; }
  100% { background-position: calc(200px + 100%) 0; }
`;

export const pulse = keyframes`
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
`;

// Main Container Styles
export const Container = styled.div`
    display: flex;
    flex-direction: column;
    justify-content: center;
    position: relative;
    z-index: 1;
    align-items: center;
    padding: 30px 0px;
    background: ${({ theme }) => theme.bg};
    
    @media (max-width: 960px) {
        padding: 25px 0px;
    }
    
    @media (max-width: 768px) {
        padding: 20px 0px;
    }
    
    @media (max-width: 480px) {
        padding: 15px 0px;
    }
    
    @media (max-width: 320px) {
        padding: 12px 0px;
    }
`;

export const Wrapper = styled.div`
    position: relative;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-direction: column;
    width: 100%;
    max-width: 1350px;
    padding: 20px 20px;
    gap: 15px;
    
    @media (max-width: 1024px) {
        max-width: 1000px;
        padding: 18px 18px;
        gap: 14px;
    }
    
    @media (max-width: 960px) {
        padding: 15px 15px;
        gap: 12px;
    }
    
    @media (max-width: 768px) {
        padding: 12px 12px;
        gap: 10px;
    }
    
    @media (max-width: 480px) {
        padding: 10px 10px;
        gap: 10px;
    }
    
    @media (max-width: 320px) {
        padding: 15px 8px;
        gap: 8px;
    }
`;

// Typography Styles
export const Title = styled.div`
    font-size: 42px;
    text-align: center;
    font-weight: 600;
    margin-top: 10px;
    color: ${({ theme }) => theme.text_primary};
    animation: ${fadeIn} 0.8s ease-out;
    line-height: 1.2;
    
    @media (max-width: 1024px) {
        font-size: 38px;
        margin-top: 8px;
    }
    
    @media (max-width: 768px) {
        margin-top: 6px;
        font-size: 32px;
    }
    
    @media (max-width: 480px) {
        font-size: 28px;
        margin-top: 5px;
    }
    
    @media (max-width: 320px) {
        font-size: 24px;
        margin-top: 4px;
    }
`;

export const Desc = styled.div`
    font-size: 18px;
    text-align: center;
    max-width: 600px;
    color: ${({ theme }) => theme.text_secondary};
    animation: ${fadeIn} 0.8s ease-out 0.2s both;
    line-height: 1.6;
    
    @media (max-width: 1024px) {
        font-size: 17px;
        max-width: 550px;
    }
    
    @media (max-width: 768px) {
        font-size: 16px;
        max-width: 500px;
    }
    
    @media (max-width: 480px) {
        font-size: 14px;
        max-width: 100%;
        padding: 0 10px;
    }
    
    @media (max-width: 320px) {
        font-size: 13px;
        padding: 0 8px;
    }
`;

// Twitter Section Styles
export const TwitterSection = styled.div`
    width: 100%;
    max-width: 650px;
    margin-top: 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 20px;
    animation: ${fadeIn} 0.8s ease-out 0.4s both;
    padding: 15px;
    
    @media (max-width: 1024px) {
        max-width: 600px;
        gap: 18px;
        padding: 14px;
        margin-top: 18px;
    }
    
    @media (max-width: 768px) {
        max-width: 550px;
        gap: 15px;
        padding: 12px;
        margin-top: 15px;
    }
    
    @media (max-width: 480px) {
        max-width: 100%;
        gap: 12px;
        padding: 10px;
        margin-top: 12px;
    }
    
    @media (max-width: 320px) {
        gap: 10px;
        padding: 8px;
        margin-top: 10px;
    }
`;

// Button Styles
export const RefreshButton = styled.button`
    background: linear-gradient(135deg, ${({ theme }) => theme.primary}, ${({ theme }) => theme.space_accent || theme.primary});
    color: ${({ theme }) => theme.white};
    border: none;
    padding: 12px 24px;
    border-radius: 25px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
    position: relative;
    overflow: hidden;
    
    &::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s;
    }
    
    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 212, 255, 0.4);
        
        &::before {
            left: 100%;
        }
    }
    
    &:active {
        transform: translateY(0);
    }
    
    &:disabled {
        opacity: 0.7;
        cursor: not-allowed;
        transform: none;
        
        &:hover {
            transform: none;
            box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
        }
    }
    
    &:focus {
        outline: 2px solid ${({ theme }) => theme.primary};
        outline-offset: 2px;
    }
    
    @media (max-width: 768px) {
        padding: 11px 22px;
        font-size: 15px;
    }
    
    @media (max-width: 480px) {
        padding: 10px 20px;
        font-size: 14px;
        gap: 6px;
    }
    
    @media (max-width: 320px) {
        padding: 9px 18px;
        font-size: 13px;
        gap: 5px;
    }
`;

export const SpinIcon = styled.div`
    width: 16px;
    height: 16px;
    border: 2px solid transparent;
    border-top: 2px solid currentColor;
    border-radius: 50%;
    animation: ${({ $isSpinning }) => $isSpinning ? spin : 'none'} 1s linear infinite;
    flex-shrink: 0;
    
    @media (max-width: 480px) {
        width: 14px;
        height: 14px;
        border-width: 1.5px;
        border-top-width: 1.5px;
    }
    
    @media (max-width: 320px) {
        width: 12px;
        height: 12px;
        border-width: 1px;
        border-top-width: 1px;
    }
`;

// Container Styles
export const TwitterContainer = styled.div`
    width: 100%;
    min-height: 400px;
    background: ${({ theme }) => theme.card};
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
    border: 1px solid ${({ theme }) => theme.border};
    transition: all 0.3s ease;
    margin: 10px 0;
    position: relative;
    overflow: hidden;
    
    &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 2px;
        background: linear-gradient(90deg, ${({ theme }) => theme.primary}, ${({ theme }) => theme.space_accent || theme.primary});
        opacity: 0.8;
    }
    
    &:hover {
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.18);
        transform: translateY(-2px);
    }
    
    @media (max-width: 1024px) {
        min-height: 380px;
        padding: 25px;
        border-radius: 14px;
    }
    
    @media (max-width: 768px) {
        padding: 20px;
        min-height: 350px;
        border-radius: 12px;
        margin: 15px 0;
    }
    
    @media (max-width: 480px) {
        padding: 15px;
        min-height: 300px;
        border-radius: 10px;
        margin: 12px 0;
    }
    
    @media (max-width: 320px) {
        padding: 12px;
        min-height: 280px;
        border-radius: 8px;
        margin: 10px 0;
    }
`;

// Loading Skeleton Styles
export const SkeletonContainer = styled.div`
    width: 100%;
    height: 400px;
    display: flex;
    flex-direction: column;
    gap: 15px;
    
    @media (max-width: 1024px) {
        height: 380px;
        gap: 14px;
    }
    
    @media (max-width: 768px) {
        height: 350px;
        gap: 12px;
    }
    
    @media (max-width: 480px) {
        height: 300px;
        gap: 10px;
    }
    
    @media (max-width: 320px) {
        height: 280px;
        gap: 8px;
    }
`;

export const SkeletonItem = styled.div`
    height: 80px;
    background: linear-gradient(
        90deg,
        ${({ theme }) => theme.card_light || theme.bgLight} 0%,
        ${({ theme }) => theme.bgLight} 50%,
        ${({ theme }) => theme.card_light || theme.bgLight} 100%
    );
    background-size: 200px 100%;
    animation: ${shimmer} 1.5s infinite;
    border-radius: 8px;
    
    &:first-child {
        height: 100px;
    }
    
    &:last-child {
        height: 60px;
    }
    
    @media (max-width: 768px) {
        height: 70px;
        border-radius: 7px;
        
        &:first-child {
            height: 90px;
        }
        
        &:last-child {
            height: 50px;
        }
    }
    
    @media (max-width: 480px) {
        height: 60px;
        border-radius: 6px;
        
        &:first-child {
            height: 80px;
        }
        
        &:last-child {
            height: 45px;
        }
    }
    
    @media (max-width: 320px) {
        height: 50px;
        border-radius: 5px;
        
        &:first-child {
            height: 70px;
        }
        
        &:last-child {
            height: 40px;
        }
    }
`;

// Error Handling Styles
export const ErrorContainer = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px 20px;
    text-align: center;
    color: ${({ theme }) => theme.text_secondary};
    
    @media (max-width: 768px) {
        padding: 35px 18px;
    }
    
    @media (max-width: 480px) {
        padding: 30px 15px;
    }
    
    @media (max-width: 320px) {
        padding: 25px 12px;
    }
`;

export const ErrorIcon = styled.div`
    font-size: 48px;
    margin-bottom: 16px;
    color: ${({ theme }) => theme.text_secondary};
    animation: ${pulse} 2s infinite;
    
    @media (max-width: 768px) {
        font-size: 42px;
        margin-bottom: 14px;
    }
    
    @media (max-width: 480px) {
        font-size: 36px;
        margin-bottom: 12px;
    }
    
    @media (max-width: 320px) {
        font-size: 32px;
        margin-bottom: 10px;
    }
`;

export const ErrorMessage = styled.p`
    font-size: 16px;
    margin-bottom: 20px;
    max-width: 400px;
    line-height: 1.5;
    
    @media (max-width: 768px) {
        font-size: 15px;
        margin-bottom: 18px;
        max-width: 350px;
    }
    
    @media (max-width: 480px) {
        font-size: 14px;
        margin-bottom: 15px;
        max-width: 100%;
    }
    
    @media (max-width: 320px) {
        font-size: 13px;
        margin-bottom: 12px;
    }
`;

export const RetryButton = styled.button`
    background: ${({ theme }) => theme.primary};
    color: ${({ theme }) => theme.white};
    border: none;
    padding: 10px 20px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
    
    &:hover {
        opacity: 0.9;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0, 212, 255, 0.3);
    }
    
    &:active {
        transform: translateY(0);
    }
    
    &:focus {
        outline: 2px solid ${({ theme }) => theme.primary};
        outline-offset: 2px;
    }
    
    @media (max-width: 768px) {
        padding: 9px 18px;
        font-size: 13px;
    }
    
    @media (max-width: 480px) {
        padding: 8px 16px;
        font-size: 12px;
    }
    
    @media (max-width: 320px) {
        padding: 7px 14px;
        font-size: 11px;
    }
`;

// Twitter Widget Responsive Styles
export const TwitterWidgetContainer = styled.div`
    width: 100%;
    min-height: 400px;
    
    /* Twitter widget responsive adjustments */
    .twitter-timeline {
        width: 100% !important;
        max-width: 100% !important;
    }
    
    @media (max-width: 768px) {
        min-height: 350px;
    }
    
    @media (max-width: 480px) {
        min-height: 300px;
    }
    
    @media (max-width: 320px) {
        min-height: 280px;
    }
`;

// Accessibility Enhancements
export const VisuallyHidden = styled.span`
    position: absolute !important;
    width: 1px !important;
    height: 1px !important;
    padding: 0 !important;
    margin: -1px !important;
    overflow: hidden !important;
    clip: rect(0, 0, 0, 0) !important;
    white-space: nowrap !important;
    border: 0 !important;
`;

export const FocusIndicator = styled.div`
    position: absolute;
    top: -2px;
    left: -2px;
    right: -2px;
    bottom: -2px;
    border: 2px solid ${({ theme }) => theme.primary};
    border-radius: inherit;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.2s ease;
    
    ${({ $isFocused }) => $isFocused && `
        opacity: 1;
    `}
`;