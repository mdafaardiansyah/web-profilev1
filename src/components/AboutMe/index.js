import React from 'react';
import HeroBgAnimation from '../HeroBgAnimation';
import {
    HeroContainer, HeroBg, HeroLeftContainer, Img,
    HeroRightContainer, HeroInnerContainer, TextLoop,
    Title, Span, SubTitle, SocialMediaIcons, SocialMediaIcon,
    ResumeButton, ButtonContainer
} from './AboutmeStyle';
import Typewriter from 'typewriter-effect';
import { Bio } from '../../data/constants';

const AboutMe = () => {
    return (
        <div id="aboutme">
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
                            src="https://firebasestorage.googleapis.com/v0/b/portfolioweb-b5005.appspot.com/o/PhotoHero%2FHeroImages2.png?alt=media&token=15b1aa4d-cc2c-4a2c-81ed-97b5afc9170a"
                            alt="hero-image2"
                        />
                    </HeroRightContainer>
                </HeroInnerContainer>
            </HeroContainer>
        </div>
    );
};

export default AboutMe;