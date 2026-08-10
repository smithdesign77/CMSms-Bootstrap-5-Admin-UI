# Bootstrap admin theme for CMS Made Simple

A Bootstrap 5 admin theme for CMS Made Simple 2.2.x, built as a compatibility
middleware layer: it extends `CmsAdminThemeBase` and re-skins the admin
backend without touching CMSms core or any module files. Not an official
CMSms project — an independent, community fork-style theme, currently beta.
Use at your own risk; test on a staging copy before deploying to a
production site.

## Known limitations

- **jQuery UI stays loaded** and a number of core/module screens
  (DesignManager, ModuleManager, FileManager, News, CMSContentManager, plus
  the core Site Preferences / My Account / System Log / Edit User Tag pages)
  call jQuery UI's `.dialog()` / `.sortable()` directly in their own
  templates, independent of this theme. Those widgets render as native,
  unstyled jQuery UI next to the rest of the Bootstrap chrome — not broken,
  just visually inconsistent. Reskinning them was out of scope for this pass.
- **No pagination** on the System Log page — not implemented (same as
  upstream CMSms, not a regression).
- **Manual install only** — this theme is not packaged as an installable
  Module Manager `.zip`. Copy the folder in by hand (see below).
- **Login page uses a separate theme setting.** CMSms resolves the
  pre-login screen from the site-wide "Master Admin Theme" preference
  (Site Admin → Global Settings), independent of the per-user "Admin theme"
  preference used everywhere after login. Set both if you want Bootstrap
  applied consistently.

## Requirements

CMS Made Simple 2.2.x (built and tested against 2.2.22 "Saskatoon"). No
extra dependencies — Bootstrap 5.3.8 and Popper are bundled in `js/` and
`css/`; jQuery UI is CMSms core's own, already present.

## Installation

1. Copy this folder to `admin/themes/Bootstrap/` in your CMSms installation.
2. Log in, open your user preferences and set "Admin theme" to Bootstrap.
3. To also theme the login screen: Site Admin → Global Settings →
   "Master Admin Theme" → Bootstrap.

## License

GPLv2, see [LICENSE](LICENSE) — this theme is a derivative of CMSms's own
GPLv2-licensed `CmsAdminThemeBase`. Bundled third-party assets (Bootstrap,
one icon derived from Font Awesome Free) carry their own licenses, see
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
