import React, { useState } from "react";

const Vote = ({ userEmail }) => {
  const handleLogout = async (e) => {
    e.preventDefault();
    
    try {
      // Get CSRF token from meta tag
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
      
      const response = await fetch('/logout', {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': csrfToken,
        },
      });
      
      if (response.redirected) {
        window.location.href = response.url;
      } else if (response.ok) {
        // Fallback redirect to root if no redirect in response
        window.location.href = '/';
      }
    } catch (error) {
      console.error('Logout error:', error);
      // Fallback - still redirect to home
      window.location.href = '/';
    }
  };

  return (
    <div className="vote-container">
      <header className="vote-header">
        <h1>VOTE.WEBSITE</h1>
        <div className="user-info">
          Signed in as {userEmail} (<a href="#" onClick={handleLogout} className="logout-link">Logout</a>)
        </div>
      </header>

      <div className="vote-content">
        <h2>Cast your vote today!</h2>

        <div className="candidates-section">
          {/* Placeholder for candidate list - will be implemented in Stage 8 */}
          <div className="candidate-item">
            <input type="radio" id="candidate1" name="candidate" value="candidate1" />
            <label htmlFor="candidate1">Cindy and The Scintillators</label>
          </div>
          <div className="candidate-item">
            <input type="radio" id="candidate2" name="candidate" value="candidate2" />
            <label htmlFor="candidate2">BTESS</label>
          </div>

          <button className="vote-button" type="button">
            Vote
          </button>
        </div>

        <div className="separator"></div>

        <div className="write-in-section">
          <p>Or, add a new candidate:</p>
          <div className="write-in-form">
            <input
              type="text"
              placeholder="Enter name..."
              className="write-in-input"
            />
            <button className="vote-button" type="button">
              Vote
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Vote;
