import React, { useState } from "react";
import { getCsrfToken } from "../utils/csrf";

const Vote = ({ userEmail, candidates }) => {
  const [selectedCandidate, setSelectedCandidate] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleLogout = async (e) => {
    e.preventDefault();

    try {
      const csrfToken = getCsrfToken();

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

  const handleVote = async (e) => {
    e.preventDefault();

    if (!selectedCandidate) {
      setError("Please select a candidate");
      return;
    }

    setIsSubmitting(true);
    setError("");

    try {
      const csrfToken = getCsrfToken();

      const response = await fetch('/votes', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({ candidate_id: selectedCandidate })
      });

      const data = await response.json();

      if (data.success) {
        // Redirect to results page
        window.location.href = data.redirect_url;
      } else {
        setError(data.errors?.join(', ') || "An error occurred while submitting your vote");
      }
    } catch (error) {
      console.error('Vote submission error:', error);
      setError("Network error. Please try again.");
    } finally {
      setIsSubmitting(false);
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
          {error && (
            <div className="alert alert-error" style={{ marginBottom: "20px" }}>
              {error}
            </div>
          )}

          {candidates && candidates.map((candidate) => (
            <div key={candidate.id} className="candidate-item">
              <input
                type="radio"
                id={`candidate-${candidate.id}`}
                name="candidate"
                value={candidate.id}
                checked={selectedCandidate === candidate.id.toString()}
                onChange={(e) => setSelectedCandidate(e.target.value)}
                disabled={isSubmitting}
              />
              <label htmlFor={`candidate-${candidate.id}`}>{candidate.name}</label>
            </div>
          ))}

          <button
            className="vote-button"
            type="button"
            disabled={!selectedCandidate || isSubmitting}
            onClick={handleVote}
          >
            {isSubmitting ? "Submitting..." : "Vote"}
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
