import React, { useState } from "react";
import { getCsrfToken } from "../utils/csrf";
import LogoutLink from "./LogoutLink";

const Vote = ({ userEmail, candidates }) => {
  const [selectedCandidate, setSelectedCandidate] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [writeInName, setWriteInName] = useState("");
  const [isSubmittingWriteIn, setIsSubmittingWriteIn] = useState(false);

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

  const handleWriteIn = async (e) => {
    e.preventDefault();

    if (!writeInName.trim()) {
      setError("Please enter a candidate name");
      return;
    }

    setIsSubmittingWriteIn(true);
    setError("");

    try {
      const csrfToken = getCsrfToken();

      const response = await fetch('/candidates', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({ name: writeInName.trim() })
      });

      const data = await response.json();

      if (data.success) {
        // Redirect to results page
        window.location.href = data.redirect_url;
      } else {
        setError(data.errors?.join(', ') || "An error occurred while adding your candidate");
      }
    } catch (error) {
      console.error('Write-in submission error:', error);
      setError("Network error. Please try again.");
    } finally {
      setIsSubmittingWriteIn(false);
    }
  };

  return (
    <div className="page-container">
      <header className="page-header">
        <h1>VOTE.WEBSITE</h1>
        <div className="user-info">
          Signed in as {userEmail} (<LogoutLink />)
        </div>
      </header>

      <div className="page-content">
        <h2>Cast your vote today!</h2>

        {error && (
          <div className="alert alert-error" style={{ marginBottom: "20px" }}>
            {error}
          </div>
        )}

        {candidates && candidates.length > 0 && (
          <>
            <div className="candidates-section">
              {candidates.map((candidate) => (
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
                className="button-primary"
                type="button"
                disabled={!selectedCandidate || isSubmitting}
                onClick={handleVote}
              >
                {isSubmitting ? "Submitting..." : "Vote"}
              </button>
            </div>

            <div className="separator"></div>
          </>
        )}

        <div className="write-in-section">
          <p>{candidates && candidates.length > 0 ? "Or, add a new candidate:" : "Please add the first candidate:"}</p>
          <div className="write-in-form">
            <input
              type="text"
              placeholder="Enter name..."
              className="form-input write-in-input"
              value={writeInName}
              onChange={(e) => setWriteInName(e.target.value)}
              disabled={isSubmittingWriteIn || isSubmitting}
            />
            <button
              className="button-primary"
              type="button"
              disabled={!writeInName.trim() || isSubmittingWriteIn || isSubmitting}
              onClick={handleWriteIn}
            >
              {isSubmittingWriteIn ? "Submitting..." : "Vote"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Vote;
