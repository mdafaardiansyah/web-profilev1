import React from 'react'
import StarfieldBackground from '../StarfieldBackground'
import { HeroContainer, HeroBg, HeroLeftContainer, Img, HeroRightContainer, HeroInnerContainer, TextLoop, Title, Span, SubTitle, ResumeButton } from './HeroStyle'
import Typewriter from 'typewriter-effect';
import { Bio } from '../../data/constants';

const HeroSection = () => {
    return (
        <div id="about">
            <HeroContainer>
                <HeroBg>
                    <StarfieldBackground />
                </HeroBg>
                <HeroInnerContainer >
                    <HeroLeftContainer id="Left">
                        <Title className="glow-text">Hi, I am <br /> {Bio.name}</Title>
                        <TextLoop>
                            I am a
                            <Span className="glow-text">
                                <Typewriter
                                    options={{
                                        strings: Bio.roles,
                                        autoStart: true,
                                        loop: true,
                                    }}
                                />
                            </Span>
                        </TextLoop>
                        <SubTitle>{Bio.summary}</SubTitle>
                        <ResumeButton href={Bio.resume} target='display'>My Resume</ResumeButton>
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
    )
}

export default HeroSection