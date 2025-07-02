import React, { useState } from 'react';
import { darkTheme, lightTheme } from './utils/Themes.js'
import Navbar from "./components/Navbar";
import './App.css';
import { BrowserRouter as Router } from 'react-router-dom';
import HeroSection from "./components/HeroSection";
import AboutMe from "./components/AboutMe";
import Skills from "./components/Skills";
import Projects from "./components/Projects";
import Footer from "./components/Footer";
import Experience from "./components/Experience";
import Education from "./components/Education";
import ProjectDetails from "./components/ProjectDetails";
import styled, { ThemeProvider } from "styled-components";
import StarfieldBackground from "./components/StarfieldBackground";
import CursorTrail from "./components/CursorTrail";

const Body = styled.div`
  background-color: ${({ theme }) => theme.bg};
  width: 100%;
  overflow-x: hidden;
  position: relative;
`

const Wrapper = styled.div`
  background: linear-gradient(38.73deg, rgba(106, 13, 173, 0.15) 0%, rgba(0, 212, 255, 0) 50%), linear-gradient(141.27deg, rgba(0, 212, 255, 0) 50%, rgba(123, 104, 238, 0.15) 100%);
  width: 100%;
  clip-path: polygon(0 0, 100% 0, 100% 100%,30% 98%, 0 100%);
  position: relative;
  z-index: 1;
`

const StarfieldWrapper = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1;
`

function App() {
  const [darkMode] = useState(true);
  const [openModal, setOpenModal] = useState({ state: false, project: null });
  console.log(openModal)
  return (
    <ThemeProvider theme={darkMode ? darkTheme : lightTheme}>
      <Router >
        <StarfieldWrapper>
          <StarfieldBackground />
        </StarfieldWrapper>
        <CursorTrail />
        <Navbar />
        <Body>
          <HeroSection />
          
          <Wrapper>
            <AboutMe />
            <Skills />
            <Experience />
          </Wrapper>
          <Projects openModal={openModal} setOpenModal={setOpenModal} />
          <Wrapper>
            <Education />
            {/* <Contact /> */}
          </Wrapper>
          <Footer />
          {openModal.state &&
            <ProjectDetails openModal={openModal} setOpenModal={setOpenModal} />
          }
        </Body>
      </Router>
    </ThemeProvider>
  );
}

export default App;
