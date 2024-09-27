import React from 'react';
import HeroBgAnimation from '../HeroBgAnimation';
import {
    HeroContainer, HeroBg, HeroLeftContainer, Img,
    HeroRightContainer, HeroInnerContainer, TextLoop,
    Title, Span, SubTitle,SocialMediaIcons,SocialMediaIcon,
    ResumeButton
} from './HeroStyle';
import Typewriter from 'typewriter-effect';
import { Bio } from '../../data/constants';

const HeroSection = () => {
    return (
        <div id="about">
            <HeroContainer>
                <HeroBg>
                    <HeroBgAnimation />
                </HeroBg>
                <HeroInnerContainer >
                    <HeroLeftContainer id="Left">
                        {/* ... (rest of your left container code) */}
                    </HeroLeftContainer>

                    <HeroRightContainer id="Right">
                        <Img
                            src="https://firebasestorage.googleapis.com/v0/b/portfolioweb-b5005.appspot.com/o/PhotoHero%2FHeroImage.png?alt=media&token=a2a6a22f-1cd7-4db4-bb45-a4604a6bc88c"
                            alt="hero-image"
                        />
                    </HeroRightContainer>
                </HeroInnerContainer>
            </HeroContainer>
        </div>
    );
};

export default HeroSection;