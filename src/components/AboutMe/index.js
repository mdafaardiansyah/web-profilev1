import React from 'react'
import HeroBgAnimation from '../HeroBgAnimation'
import { HeroContainer, HeroBg, HeroLeftContainer, Img, HeroRightContainer, HeroInnerContainer, TextLoop, Title, Span, SubTitle,SocialMediaIcons,SocialMediaIcon, ResumeButton, ButtonContainer } from './AboutmeStyle'
import HeroImg2 from '../../images/HeroImages2.png'
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
                        <Title>About Me</Title>
                        <SubTitle>{Bio.description}</SubTitle>
                        <ButtonContainer>
                            <ResumeButton href={Bio.linkedin} target='display'>LinkedIn</ResumeButton>
                            <ResumeButton href={Bio.github} target='display'>Github</ResumeButton>
                            <ResumeButton href={Bio.email} target='display'>Email</ResumeButton>
                        </ButtonContainer> 
                    </HeroLeftContainer>

                    <HeroRightContainer id="Right">

                        <Img src={HeroImg2} alt="hero-image2" />
                    </HeroRightContainer>
                </HeroInnerContainer>

            </HeroContainer>
        </div>
    )
}

export default AboutMe