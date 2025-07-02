import React, { useEffect, useRef } from 'react';
import styled from 'styled-components';

const StarfieldContainer = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  z-index: 0;
`;

const Canvas = styled.canvas`
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
`;

const StarfieldBackground = () => {
  const canvasRef = useRef(null);
  const animationRef = useRef(null);
  const starsRef = useRef([]);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    const createStars = (count) => {
      const stars = [];
      for (let i = 0; i < count; i++) {
        stars.push({
          x: Math.random() * canvas.width,
          y: Math.random() * canvas.height,
          z: Math.random() * 1000,
          prevX: 0,
          prevY: 0,
        });
      }
      return stars;
    };

    const updateStars = (stars, speed) => {
      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;

      stars.forEach(star => {
        star.prevX = star.x;
        star.prevY = star.y;
        
        star.z -= speed;
        
        if (star.z <= 0) {
          star.x = Math.random() * canvas.width;
          star.y = Math.random() * canvas.height;
          star.z = 1000;
        }
        
        star.x = (star.x - centerX) * (1000 / star.z) + centerX;
        star.y = (star.y - centerY) * (1000 / star.z) + centerY;
      });
    };

    const drawStars = (stars) => {
      ctx.fillStyle = '#0a0a0f';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      
      stars.forEach(star => {
        const opacity = 1 - star.z / 1000;
        const size = (1 - star.z / 1000) * 2;
        
        // Draw star trail
        ctx.strokeStyle = `rgba(0, 212, 255, ${opacity * 0.5})`;
        ctx.lineWidth = size;
        ctx.beginPath();
        ctx.moveTo(star.prevX, star.prevY);
        ctx.lineTo(star.x, star.y);
        ctx.stroke();
        
        // Draw star
        ctx.fillStyle = `rgba(255, 255, 255, ${opacity})`;
        ctx.shadowColor = '#00d4ff';
        ctx.shadowBlur = size * 2;
        ctx.beginPath();
        ctx.arc(star.x, star.y, size, 0, Math.PI * 2);
        ctx.fill();
        ctx.shadowBlur = 0;
      });
    };

    const animate = () => {
      updateStars(starsRef.current, 2);
      drawStars(starsRef.current);
      animationRef.current = requestAnimationFrame(animate);
    };

    resizeCanvas();
    starsRef.current = createStars(200);
    animate();

    window.addEventListener('resize', resizeCanvas);

    return () => {
      window.removeEventListener('resize', resizeCanvas);
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, []);

  return (
    <StarfieldContainer>
      <Canvas ref={canvasRef} />
    </StarfieldContainer>
  );
};

export default StarfieldBackground;