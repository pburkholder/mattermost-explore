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

- would we be able to legally run using the MM license?
  - Unclear. It seems that this lets use anything that's not verboten:
>>>
You may, however, utilize the free version of the Software (with several features not enabled) under this license without a license key or subscription provided that you otherwise comply with the terms and conditions of this Agreement
  - but https://docs.mattermost.com/administration/config-settings.html?highlight=gitlab#oauth-2-0 
    - indicates that Oauth2.0 is an EE10 feature, although Gitlab auth is not.

- would we be able to use gov authentiation?

https://login.fr.cloud.gov/oauth/authorize?client_id=822652a&response_type=code&redirect_uri=https%3A%2F%2Ftock.18f.gov%2Fauth%2Fcallback&state=meNpIAJMPKQ8C8kBI

At view-source:https://login.fr.cloud.gov/profile - have the 

  - Auth is one thing - how does MM get the username, fname, lname and email?
    From login.fr.cloud.gov/profile? Or from UAA? That plus/v1/people/me from
    Google or "UserApiEndpoint": "https://graph.microsoft.com/v1.0/me"


I'm gueessing uaa.fr.cloud.gov/userinfo, which is described at https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-APIs.rst#openid-user-info-endpoint-get-userinfo as: OpenID User Info Endpoint: GET /userinfo, which is described in Mattermost docs, perhaps, as "https://www.googleapis.com/plus/v1/people/me as the User API Endpoint"


How do I test this locally, and translate to CF?

OR DO I JUST USE A REVERSE PROXY LIKE: https://github.com/bitly/oauth2_proxy

Which means this might work running locally 

=======

Running MM with DockerCompose locally works okay provided you just
comment away the docker compose lines with /etc/localtime

I can use the oauth provider with this stanza in config.json:

```javascript
    "GitLabSettings": {
        "Enable": true,
        "Secret": "secret",
        "Id": "GUID",
        "Scope": "openid",
        "AuthEndpoint": "https://login.fr.cloud.gov/oauth/authorize",
        "TokenEndpoint": "https://uaa.fr.cloud.gov/oauth/token",
        "UserApiEndpoint": "https://uaa.fr.cloud.gov/userinfo"
    },
```

And then using mattermost.localdomain as the name, 

```
127.0.0.1       localhost localhost.localdomain mattermost.localdomain
```

and... 

```
cf bind-service mattermost-coe mm-local-oauth -c '{"redirect_uri": ["http://mattermost.localdomain/signup/gitlab/complete"]}'
```

The whole things craps out with:

```
{"level":"error","ts":1540837539.8410792,"caller":"api4/oauth.go:504","msg":"User.IsValid: Your password must contain at least 5 characters., "}
{"level":"error","ts":1540837557.3267305,"caller":"api4/oauth.go:504","msg":"LoginByOAuth: Could not parse auth data out of gitlab user object, "}
```

The GitLab oauth integration is in the opensource MM:

https://github.com/mattermost/mattermost-server/blob/master/api4/oauth.go
https://github.com/mattermost/mattermost-server/blob/master/model/gitlab.go
https://github.com/mattermost/mattermost-server/blob/master/model/gitlab/gitlab.go

SOOOO

- could build MM with UAA.go instead of GitLab
- run MM with email auth and put it behind Oauth reverse proxy.

gitlab /user

```
{
  "id": 1,
  "username": "john_smith",
  "email": "john@example.com",
  "name": "John Smith",
  "state": "active",
```

uaa /userinfo
```
{
  "user_id" : "61b3028d-5525-4449-9cc4-17b762a6b46e",
  "user_name" : "7PUNHB@test.org",
  "name" : "PasswordResetUserFirst PasswordResetUserLast",
  "given_name" : "PasswordResetUserFirst",
  "family_name" : "PasswordResetUserLast",
  "phone_number" : "+15558880000",
  "email" : "7PUNHB@test.org",
  "email_verified" : true,
```

https://github.com/mattermost/mattermost-server/blob/master/model/gitlab/gitlab.go:

```
type GitLabUser struct {
	Id       int64  `json:"id"`
	Username string `json:"username"`
	Login    string `json:"login"`
	Email    string `json:"email"`
	Name     string `json:"name"`
}
```

I could experiment with GitLab https://docs.gitlab.com/ee//integration/oauth_provider.html#doc-nav as the OAuth server to see how it works....


