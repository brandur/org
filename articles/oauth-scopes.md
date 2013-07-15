## The Spec

[RFC 6749](http://tools.ietf.org/html/rfc6749) describes how scope should be implemented according to the proposed OAuth 2 standard:

> The authorization and token endpoints allow the client to specify the scope of the access request using the "scope" request parameter. In turn, the authorization server uses the "scope" response parameter to inform the client of the scope of the access token issued.
>
> The value of the scope parameter is expressed as a list of space- delimited, case-sensitive strings. The strings are defined by the authorization server. If the value contains multiple space-delimited strings, their order does not matter, and each string adds an additional access range to the requested scope.
>
>     scope       = scope-token *( SP scope-token )
>     scope-token = 1*( %x21 / %x23-5B / %x5D-7E )
>
> The authorization server MAY fully or partially ignore the scope requested by the client, based on the authorization server policy or the resource owner's instructions. If the issued access token scope is different from the one requested by the client, the authorization server MUST include the "scope" response parameter to inform the client of the actual scope granted.
>
> If the client omits the scope parameter when requesting authorization, the authorization server MUST either process the request using a pre-defined default value or fail the request indicating an invalid scope. The authorization server SHOULD document its scope requirements and default value (if defined).

## From Around the Web

### App.net

    basic stream update_profile

http://developers.app.net/docs/authentication/#scopes

### Facebook

Comma separated.

    email,read_stream,user_actions.video,user_actions:APP_NAMESPACE

https://developers.facebook.com/docs/reference/login/#permissions

### GitHub

* Developer friendly headers `X-OAuth-Scopes` and `X-Accepted-OAuth-Scopes`.
* Scopes namespaced via colon. `user:email` is a subset of the permissions allowed by `user`.

```
gist repo user user:email
```

http://developer.github.com/v3/oauth/#scopes

### Google

Start with `openid`, then include either or both of `email` and `profile`

    openid profile email https://www.googleapis.com/auth/drive.file

https://developers.google.com/accounts/docs/OAuth2Login

### Instagram

    likes+comments

http://instagram.com/developer/authentication

### LinkedIn

    r_basicprofile r_emailaddress rw_groups w_messages

https://developer.linkedin.com/documents/authentication#granting

### Salesforce

    api refresh_token web

http://help.salesforce.com/help/doc/en/remoteaccess_oauth_scopes.htm

### Shopify

    read_customers write_script_tags, write_shipping

http://docs.shopify.com/api/tutorials/oauth

### Windows Live ID

Prefixed with `wl.` for Windows Live.

    wl.basic wl.offline_access wl.contacts_photos

http://msdn.microsoft.com/en-us/library/live/hh243646.aspx

## Heroku OAuth
