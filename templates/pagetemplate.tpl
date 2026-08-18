<!doctype html>
<html lang="{$lang|truncate:'2':''}" dir="{$lang_dir}">
<head>
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="0">
	{$thetitle=$pagetitle}
	{if $thetitle && $subtitle}{$thetitle="{$thetitle} - {$subtitle}"}{/if}
	{if $thetitle}{$thetitle="{$thetitle} - "}{/if}
	<meta charset="utf-8" />
	<title>{$thetitle}{sitename}</title>
	<base href="{$config.admin_url}/" />
	<meta name="generator" content="CMS Made Simple - Bootstrap admin theme" />
	<meta name="robots" content="noindex, nofollow" />
	<meta name="referrer" content="origin"/>
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	{* Applied before first paint (synchronous, before <body> exists) so a
	   remembered "narrow sidebar" preference doesn't flash full-width for a
	   frame on every page load - same purpose as the usual dark-mode-flash
	   prevention snippet, just for sidebar width. See admin-bridge.js for
	   the toggle button that writes this same localStorage key. *}
	{literal}
	<script>
	if (localStorage.getItem('bs-sidebar-narrow') === '1') {
	    document.documentElement.classList.add('bs-sidebar-narrow');
	    // navigation.tpl marks the active section's submenu "show" server-side
	    // on every full page load, regardless of narrow mode - fine inline in
	    // wide mode, but in narrow mode that submenu is a flyout, so it would
	    // pop open unprompted on every navigation. Suppress the very first
	    // paint synchronously (before the nav markup is even parsed) so there
	    // is no flash of the flyout; admin-bridge.js's ready handler then
	    // removes the actual "show" state (and this override) once, so every
	    // click afterwards goes through Bootstrap's own collapse toggle
	    // untouched.
	    document.write('<style id="bs-sidebar-narrow-presuppress">#bs-sidebar-nav>.nav-item>.bs-sidebar-sub.show{display:none!important}</style>');
	}
	</script>
	{/literal}
	<link rel="shortcut icon" href="{$config.admin_url}/themes/Bootstrap/images/favicon/cmsms-favicon.ico"/>
	<link rel='apple-touch-icon' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-iphone.png' />
	<link rel='apple-touch-icon' sizes='72x72' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-ipad.png' />
	<link rel='apple-touch-icon' sizes='114x114' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-iphone4.png' />
	<link rel='apple-touch-icon' sizes='144x144' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-ipad3.png' />
	<meta name='msapplication-TileImage' content='{$config.admin_url}/themes/Bootstrap/images/favicon/ms-application-icon.png' />
	<link rel="stylesheet" href="{$config.admin_url}/themes/Bootstrap/css/bootstrap.min.css" />
	<link rel="stylesheet" href="style.php?{$secureparam}" />
	{* include_css=1: jQuery UI's own theme CSS is required for the ~17 core/module
	   call sites that use $(...).dialog()/.sortable()/.button() directly (see
	   map.md) - without it those widgets are JS-functional but completely
	   unstyled (no border/radius/spacing at all), which is worse than the
	   "looks like classic jQuery UI, not Bootstrap" we actually want for them.
	   Confirmed jquery-ui-1.10.4.custom.min.css only ever qualifies selectors
	   with a .ui-* class (no bare table/a/input/button/th/td rules), so it
	   can't clash with our own element-level fallback CSS in style.css. *}
	{cms_jquery exclude="cms_admin" include_css=1 append="`$config.admin_url`/themes/Bootstrap/js/bootstrap.bundle.min.js,`$config.admin_url`/themes/Bootstrap/js/admin-bridge.js"}
	{$headertext|default:''}
</head>
<body id="{$pagetitle|md5}" class="bs-{$pagealias}">
	<nav class="navbar navbar-expand-lg navbar-dark bs-topbar sticky-top">
		<div class="container-fluid">
			<button class="btn btn-link text-light d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#bs-sidebar" aria-controls="bs-sidebar">&#9776;</button>
			{* Desktop-only: narrows the sidebar to icons-only instead of hiding it
			   entirely (that's what the mobile offcanvas button above already
			   does) - see admin-bridge.js for the click handler and
			   css/style.css's .bs-sidebar-narrow rules for the actual layout. *}
			<button id="bs-sidebar-narrow-toggle" class="btn btn-link text-light d-none d-lg-inline-block p-0 me-2" type="button" title="{'open'|lang}/{'close'|lang}">&#9776;</button>
			<a class="navbar-brand" href="index.php?{$secureparam}">{'adminpaneltitle'|lang} - {sitename}</a>
			<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#bs-topnav">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="bs-topnav">
				{include file='shortcuts.tpl'}
			</div>
		</div>
	</nav>

	<div class="bs-shell">
		<div class="offcanvas-lg offcanvas-start bs-sidebar" tabindex="-1" id="bs-sidebar">
			<div class="offcanvas-header d-lg-none">
				<h5 class="offcanvas-title">{'home'|lang}</h5>
				<button type="button" class="btn-close" data-bs-dismiss="offcanvas" data-bs-target="#bs-sidebar"></button>
			</div>
			<div class="offcanvas-body d-block p-0">
				{include file='navigation.tpl' nav=$theme->get_navigation_tree()}
			</div>
		</div>

		<main class="bs-main">
			<div class="container-fluid py-3">
				{include file='breadcrumbs.tpl' items=$theme->get_breadcrumbs()}
				{include file='messages.tpl'}
				<div class="d-flex align-items-center mb-3">
					{if isset($module_icon_url)}<img src="{$module_icon_url}" alt="{$module_name|default:''}" width="32" height="32" class="me-2">{/if}
					{if $pagetitle}<h1 class="h3 mb-0">{$pagetitle}</h1>{/if}
				</div>
				{if $pagetitle && $subtitle}<h2 class="h6 text-muted">{$subtitle}</h2>{/if}

				<div class="bs-content-scroll">{$content}</div>
			</div>
		</main>
	</div>

	{include file='footer.tpl'}
	{$footertext|default:''}
</body>
</html>
