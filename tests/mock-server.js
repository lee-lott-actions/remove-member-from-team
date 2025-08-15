const express = require('express');
const app = express();
app.use(express.json());

app.delete('/orgs/:owner/teams/:team_slug/memberships/:username', (req, res) => {
  console.log(`Mock intercepted: DELETE /orgs/${req.params.owner}/teams/${req.params.team_slug}/memberships/${req.params.username}`);
  console.log('Request headers:', JSON.stringify(req.headers));

  // Simulate different responses based on username, team_slug, and owner
  if (req.params.owner === 'test-owner' && req.params.team_slug === 'test-team' && req.params.username === 'test-user') {
    res.status(204).send();
  } else if (req.params.username === 'non-existing-user') {
    res.status(404).json({ message: 'Not Found: User is not a member of the team' });
  } else if (req.params.team_slug === 'non-existing-team') {
    res.status(404).json({ message: 'Not Found: Team does not exist' });
  } else {
    res.status(404).json({ message: 'Not Found: Team or user does not exist' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
