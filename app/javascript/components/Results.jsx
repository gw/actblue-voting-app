import React from "react";
import LogoutLink from "./LogoutLink";

const Results = ({ candidates, userEmail }) => {
  return (
    <div className="page-container">
      <header className="page-header">
        <h1>VOTE.WEBSITE</h1>
        {userEmail && (
          <div className="user-info">
            Signed in as {userEmail} (<LogoutLink />)
          </div>
        )}
      </header>

      <div className="page-content">
        <h2>Results</h2>

        <div className="results-table-container">
          <table className="results-table">
            <thead>
              <tr>
                <th>Candidate</th>
                <th>Votes</th>
              </tr>
            </thead>
            <tbody>
              {candidates.map((candidate, index) => (
                <tr key={candidate.id}>
                  <td>{candidate.name}</td>
                  <td>{candidate.vote_count}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Results;
