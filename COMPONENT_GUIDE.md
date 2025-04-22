# Component Development Guide

## Overview

This guide provides detailed information on how to develop and modify components for the portfolio website. It is intended for developers who want to extend or customize the existing components.

## Component Architecture

Each component in the project follows a similar structure:

```
ComponentName/
├── index.js       # Main component code
├── ComponentStyle.js  # Styled components for styling
```

## Creating a New Component

### Step 1: Create the Component Directory

Create a new directory under `src/components/` with your component name.

### Step 2: Create the Component Files

Create the following files in your component directory:

1. `index.js` - Main component code
2. `ComponentNameStyle.js` - Styled components for styling

### Step 3: Implement the Component

Here's a template for a new component:

```jsx
// index.js
import React from 'react'
import { Container, Title, Content } from './ComponentNameStyle'

const ComponentName = () => {
  return (
    <Container id="component-id">
      <Title>Component Title</Title>
      <Content>
        {/* Component content goes here */}
      </Content>
    </Container>
  )
}

export default ComponentName
```

```jsx
// ComponentNameStyle.js
import styled from 'styled-components'

export const Container = styled.div`
  width: 100%;
  padding: 50px 0;
  background-color: ${({ theme }) => theme.bgLight};
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
`

export const Title = styled.h2`
  font-size: 42px;
  font-weight: 600;
  color: ${({ theme }) => theme.text_primary};
  margin-bottom: 20px;
  text-align: center;
  
  @media screen and (max-width: 768px) {
    font-size: 32px;
  }
`

export const Content = styled.div`
  width: 100%;
  max-width: 1100px;
  padding: 0 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
`
```

### Step 4: Add the Component to App.js

Import your component in `App.js` and add it to the component hierarchy:

```jsx
import ComponentName from './components/ComponentName';

// Then add it to the JSX structure
<ComponentName />
```

## Modifying Existing Components

### Updating Content

To update the content of existing components, modify the data in `src/data/constants.js`. This file contains all the text content, links, and configuration for the website.

### Styling Components

To modify the styling of existing components:

1. Locate the component's style file (e.g., `HeroSectionStyle.js`)
2. Update the styled-components as needed
3. For global style changes, modify the theme in `src/utils/Themes.js`

## Theme System

The website uses a theme system for consistent styling. To use theme variables in your components:

```jsx
import styled from 'styled-components'

export const StyledElement = styled.div`
  background-color: ${({ theme }) => theme.bg};
  color: ${({ theme }) => theme.text_primary};
`
```

Available theme variables:

- `bg`: Background color
- `bgLight`: Lighter background color
- `primary`: Primary accent color
- `text_primary`: Primary text color
- `text_secondary`: Secondary text color
- `card`: Card background color
- `button`: Button color

## Responsive Design

All components should be responsive. Use media queries in styled-components:

```jsx
export const Container = styled.div`
  width: 100%;
  padding: 40px 0;
  
  @media screen and (max-width: 768px) {
    padding: 20px 0;
  }
  
  @media screen and (max-width: 480px) {
    padding: 10px 0;
  }
`
```

Common breakpoints:
- Mobile: 480px
- Tablet: 768px
- Desktop: 1024px

## Adding New Sections

To add a completely new section to the website:

1. Create a new component following the steps above
2. Add the component to `App.js`
3. If needed, add new data to `constants.js`
4. Consider wrapping the component in the `Wrapper` component for consistent styling

```jsx
<Wrapper>
  <YourNewComponent />
</Wrapper>
```

## Best Practices

1. **Component Organization**: Keep components focused on a single responsibility
2. **Data Management**: Store all content in `constants.js`
3. **Styling**: Use styled-components and theme variables for consistent styling
4. **Responsive Design**: Always design components to work on all screen sizes
5. **Performance**: Optimize images and use React.memo for complex components
6. **Accessibility**: Use semantic HTML and proper ARIA attributes
7. **Code Style**: Follow the existing code style and naming conventions

## Common Patterns

### Section Component Pattern

Most section components follow this pattern:

```jsx
const SectionComponent = () => {
  return (
    <Container id="section-id">
      <Title>Section Title</Title>
      <Description>Section description text</Description>
      <Content>
        {/* Section content */}
      </Content>
    </Container>
  )
}
```

### Card Component Pattern

For displaying items in a grid (like projects or skills):

```jsx
const CardGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 16px;
  width: 100%;
`

const Card = styled.div`
  background-color: ${({ theme }) => theme.card};
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
`

// Usage
<CardGrid>
  {items.map((item) => (
    <Card key={item.id}>
      {/* Card content */}
    </Card>
  ))}
</CardGrid>
```

## Testing Components

To test your components during development:

1. Run the development server: `npm start`
2. Open your browser to `http://localhost:3000`
3. Use browser developer tools to inspect and debug components
4. Test on different screen sizes using the responsive design mode

## Troubleshooting

### Component Not Rendering

- Check that the component is properly imported and included in the JSX
- Verify that there are no JavaScript errors in the console
- Ensure that conditional rendering logic is correct

### Styling Issues

- Check that theme variables are being used correctly
- Verify that styled-components are properly exported and imported
- Inspect the component with browser developer tools to see applied styles

### Data Not Displaying

- Verify that the data structure in `constants.js` matches what the component expects
- Check for typos in property names
- Use console.log to debug data flow