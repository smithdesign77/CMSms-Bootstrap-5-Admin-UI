{strip}
<ul class="navbar-nav ms-auto align-items-lg-center">
	<li class="nav-item">
		{if isset($module_help_url)}
			<a class="nav-link" href="{$module_help_url}" title="{'module_help'|lang}">{'module_help'|lang}</a>
		{else}
			<a class="nav-link" href="https://docs.cmsmadesimple.org/" rel="external" target="_blank" title="{'documentation'|lang}">{'documentation'|lang}</a>
		{/if}
	</li>
	{if isset($marks)}
	<li class="nav-item dropdown">
		<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" title="{'bookmarks'|lang}">{'bookmarks'|lang}</a>
		<ul class="dropdown-menu dropdown-menu-end">
			{if is_array($marks) && count($marks) > 0}
				<li><h6 class="dropdown-header">{'user_created'|lang}</h6></li>
				{foreach $marks as $mark}
				<li><a class="dropdown-item" href="{$mark->url}">{$mark->title}</a></li>
				{/foreach}
				<li><hr class="dropdown-divider"></li>
			{/if}
			<li><h6 class="dropdown-header">{'help'|lang}</h6></li>
			<li><a class="dropdown-item" rel="external" target="_blank" href="https://docs.cmsmadesimple.org">{'documentation'|lang}</a></li>
			<li><a class="dropdown-item" rel="external" target="_blank" href="https://forum.cmsmadesimple.org">{'forums'|lang}</a></li>
		</ul>
	</li>
	{/if}
	{$my_alerts=$theme->get_my_alerts()}
	{if !empty($my_alerts)}
		{$num_alerts=count($my_alerts)}
		<li class="nav-item dropdown">
			<a class="nav-link dropdown-toggle position-relative" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" title="{lang('notifications_to_handle2',$num_alerts)}">
				{'notifications'|lang}
				<span class="badge rounded-pill bg-danger">{$num_alerts}</span>
			</a>
			<ul class="dropdown-menu dropdown-menu-end p-2 bs-alerts-menu">
				{foreach $my_alerts as $one}
				<li class="d-flex justify-content-between align-items-start px-2 py-1 bs-alert-row" data-alert-name="{$one->get_prefname()}">
					<div class="pe-2">
						<strong class="d-block">{$one->get_title()|default:lang('alert')}</strong>
						<span class="small">{$one->get_message()}</span>
					</div>
					<button type="button" class="btn-close bs-alert-dismiss flex-shrink-0" aria-label="{lang('remove_alert')}"></button>
				</li>
				{/foreach}
			</ul>
		</li>
	{/if}
	{if isset($myaccount)}
	<li class="nav-item dropdown">
		<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">{$user->username}</a>
		<ul class="dropdown-menu dropdown-menu-end">
			<li><a class="dropdown-item" href="myaccount.php?{$secureparam}">{'myaccount'|lang}</a></li>
			{if isset($marks)}<li><a class="dropdown-item" href="listbookmarks.php?{$secureparam}">{'managebookmarks'|lang}</a></li>{/if}
		</ul>
	</li>
	{else}
	<li class="nav-item">
		<span class="nav-link disabled">{$user->username}</span>
	</li>
	{/if}
	<li class="nav-item">
		<a class="nav-link" href="{root_url}/index.php" rel="external" target="_blank" title="{'viewsite'|lang}">{'viewsite'|lang}</a>
	</li>
	<li class="nav-item">
		<a class="nav-link" href="logout.php?{$secureparam}" title="{'logout'|lang}" {if isset($is_sitedown)}onclick="return confirm('{'maintenance_warning'|lang|escape:'javascript'}')"{/if}>{'logout'|lang}</a>
	</li>
</ul>
{/strip}
