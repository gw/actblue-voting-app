import React from "react";

const Results = ({ candidates }) => {
  return (
    <div className="results-container">
      <header className="results-header">
        <h1>VOTE.WEBSITE</h1>
      </header>

      <div className="results-content">
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