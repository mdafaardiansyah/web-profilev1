import React from 'react';
import { XEmbed } from 'react-social-media-embed';
import { Bio, DailyTweets } from '../../data/constants';
import {
    Container,
    Wrapper,
    Title,
    Desc,
    TwitterSection,
    TwitterContainer
} from './TwitterFeedStyle';

const TwitterFeed = () => {
    return (
        <Container id="twitter-feed">
            <Wrapper>
                <Title>Latest Updates</Title>
                <Desc>
                    Follow my post and get updates about my latest projects and articles on X.
                </Desc>
                
                <TwitterSection>
                    <TwitterContainer>
                        <div style={{ 
                            display: 'flex', 
                            justifyContent: 'center',
                            alignItems: 'center',
                            width: '100%',
                            maxWidth: '550px',
                            margin: '20px auto',
                            padding: '15px',
                            borderRadius: '12px',
                            backgroundColor: 'rgba(255, 255, 255, 0.02)',
                            border: '1px solid rgba(255, 255, 255, 0.1)',
                            boxShadow: '0 4px 20px rgba(0, 0, 0, 0.1)'
                        }}>
                            <XEmbed 
                                url={DailyTweets.featuredTweet} 
                                width={550}
                                placeholderImageUrl="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='550' height='400' viewBox='0 0 550 400'%3E%3Crect width='550' height='400' fill='%23f0f0f0'/%3E%3Ctext x='50%25' y='50%25' dominant-baseline='middle' text-anchor='middle' font-family='Arial, sans-serif' font-size='16' fill='%23666'%3EMemuat konten Twitter...%3C/text%3E%3C/svg%3E"
                                placeholderSpinner={<div style={{
                                    display: 'flex',
                                    justifyContent: 'center',
                                    alignItems: 'center',
                                    height: '400px',
                                    fontSize: '16px',
                                    color: '#666',
                                    padding: '20px'
                                }}>Memuat konten Twitter...</div>}
                                style={{
                                    maxWidth: '100%',
                                    width: '100%',
                                    borderRadius: '8px',
                                    overflow: 'hidden',
                                    boxShadow: '0 2px 10px rgba(0, 0, 0, 0.1)'
                                }}
                            />
                        </div>
                    </TwitterContainer>
                </TwitterSection>
            </Wrapper>
        </Container>
    );
};

export default TwitterFeed;