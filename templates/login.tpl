<!doctype html>
<html lang="{$lang|truncate:'2':''}">
<head>
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="0">
	<meta charset="{$encoding}" />
	<title>{'logintitle'|lang} - {sitename}</title>
	<base href="{$config.admin_url}/" />
	<meta name="robots" content="noindex, nofollow" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link rel="shortcut icon" href="{$config.admin_url}/themes/Bootstrap/images/favicon/cmsms-favicon.ico"/>
	<link rel='apple-touch-icon' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-iphone.png' />
	<link rel='apple-touch-icon' sizes='72x72' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-ipad.png' />
	<link rel='apple-touch-icon' sizes='114x114' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-iphone4.png' />
	<link rel='apple-touch-icon' sizes='144x144' href='{$config.admin_url}/themes/Bootstrap/images/favicon/apple-touch-icon-ipad3.png' />
	<meta name='msapplication-TileImage' content='{$config.admin_url}/themes/Bootstrap/images/favicon/ms-application-icon.png' />
	<link rel="stylesheet" href="{$config.admin_url}/themes/Bootstrap/css/bootstrap.min.css" />
	<link rel="stylesheet" href="{$config.admin_url}/themes/Bootstrap/css/style.css" />
	{cms_jquery exclude="cms_admin" append="`$config.admin_url`/themes/Bootstrap/js/bootstrap.bundle.min.js"}
</head>
<body class="bs-login bg-light d-flex align-items-center py-4">
	<div class="container">
		<div class="row justify-content-center">
			<div class="col-12 col-sm-10 col-md-8 col-lg-6">
				<div class="card shadow">
					<div class="card-body p-4">
						{* Same optional-override convention as pagetemplate.tpl's
						   navbar-brand - see README.md. *}
						{if file_exists('themes/Bootstrap/images/my-login.png')}
							<div class="text-center mb-3"><img src="{$config.admin_url}/themes/Bootstrap/images/my-login.png" class="img-fluid" style="max-height:60px" alt=""></div>
						{elseif file_exists('themes/Bootstrap/images/default-login.png')}
							<div class="text-center mb-3"><img src="{$config.admin_url}/themes/Bootstrap/images/default-login.png" class="img-fluid" style="max-height:60px" alt=""></div>
						{/if}
						<h1 class="h4 text-center mb-3">{'logintitle'|lang}</h1>

						{if isset($error)}<div class="alert alert-danger">{$error}</div>{/if}
						{if isset($warninglogin)}<div class="alert alert-warning">{$warninglogin}</div>{/if}
						{if isset($acceptlogin)}<div class="alert alert-success">{$acceptlogin}</div>{/if}
						{if isset($smarty.get.forgotpw) && !empty($smarty.get.forgotpw)}<div class="alert alert-info">{'forgotpwprompt'|lang}</div>{/if}
						{if isset($changepwhash) && !empty($changepwhash)}<div class="alert alert-warning">{'passwordchange'|lang}</div>{/if}

						<form method="post" action="login.php">
							{assign var='usernamefld' value='username'}
							{if isset($smarty.get.forgotpw)}{assign var='usernamefld' value='forgottenusername'}{/if}

							<div class="mb-3">
								<label for="lbusername" class="form-label">{'username'|lang}</label>
								<input id="lbusername" class="form-control" placeholder="{'username'|lang}" name="{$usernamefld}" type="text" autofocus="autofocus" />
							</div>

							{if isset($smarty.get.forgotpw) && !empty($smarty.get.forgotpw)}
								<input type="hidden" name="forgotpwform" value="1" />
							{/if}

							{if !isset($smarty.get.forgotpw) && empty($smarty.get.forgotpw)}
							<div class="mb-3">
								<label for="lbpassword" class="form-label">{'password'|lang}</label>
								<input id="lbpassword" class="form-control" placeholder="{'password'|lang}" name="password" type="password" maxlength="100"/>
							</div>
							{/if}

							{if isset($changepwhash) && !empty($changepwhash)}
							<div class="mb-3">
								<label for="lbpasswordagain" class="form-label">{'passwordagain'|lang}</label>
								<input id="lbpasswordagain" class="form-control" name="passwordagain" type="password" placeholder="{'passwordagain'|lang}" maxlength="100" />
							</div>
								<input type="hidden" name="forgotpwchangeform" value="1" />
								<input type="hidden" name="changepwhash" value="{$changepwhash}" />
							{/if}

							<div class="d-flex gap-2">
								<button class="btn btn-primary flex-fill" name="loginsubmit" type="submit">{'submit'|lang}</button>
								<button class="btn btn-outline-secondary" name="logincancel" type="submit">{'cancel'|lang}</button>
							</div>
						</form>

						<p class="text-center small mt-3 mb-0">
							<a href="login.php?forgotpw=1">{'lostpw'|lang}</a>
						</p>
					</div>
				</div>
				<p class="text-center small text-muted mt-3">
					<a href="{root_url}" title="{'goto'|lang} {sitename}">{'goto'|lang} {sitename}</a>
				</p>
				<p class="text-center small text-muted">
					Copyright &copy; <a rel="external" href="http://www.cmsmadesimple.org">CMS Made Simple&trade;</a>
				</p>
			</div>
		</div>
	</div>
</body>
</html>
