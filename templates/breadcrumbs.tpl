{if count($items)}
{strip}
<nav aria-label="breadcrumb">
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="{$config.admin_url}">{'home'|lang}</a></li>
		{foreach from=$items item='one' name='breadcrumb'}
		{* The last crumb is the menu entry matching the request (e.g. a
		   module's overview), not necessarily the page itself - on a sub
		   page like admin_edit_message it is the way back, so it stays a
		   link (as in OneEleven) and gets no aria-current="page". *}
		<li class="breadcrumb-item{if $smarty.foreach.breadcrumb.last} active{/if}">
			{if !empty($one.url)}<a href="{$one.url}" title="{if !empty($one.description)}{$one.description}{else}{$one.title}{/if}">{$one.title}</a>{else}{$one.title}{/if}
		</li>
		{/foreach}
	</ol>
</nav>
{/strip}
{/if}
