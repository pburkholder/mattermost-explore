This is a proof-of-concept around running Mattermost in cloud.gov for 18F Path
Analyses and/or the CoEs.

There seem to be licensing/procurement issues with running Slack in multiple
teams for vendors and agency partners.  - TRUE?

I've been able to demonstrate the MM will run on cloud.gov as a Docker image
with postgres backing. I've also stared in on running it with the cloud.gov
identity provider. I think it has real promise. The kickers are:

- would agency/vendor partners be able to use it?
  - I think so, at least the web client, since it would be under the
    app.cloud.gov domain

- would we be able to legally run it in cloud.gov?
  - Maybe. It works in a sandbox, and but there's the 90-day limit and
    18F/TTS/CoE really ought to get a Prototyping account. Since there's
    probably money on the CoE side it's only an MOU, it should be doable.

- would we be able to use the MM license?
