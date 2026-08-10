{if count($items)}
{strip}
<nav aria-label="breadcrumb">
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="{$config.admin_url}">{'home'|lang}</a></li>
		{foreach from=$items item='one' name='breadcrumb'}
		<li class="breadcrumb-item{if $smarty.foreach.breadcrumb.last} active{/if}"{if $smarty.foreach.breadcrumb.last} aria-current="page"{/if}>
			{if !empty($one.url) && !$smarty.foreach.breadcrumb.last}<a href="{$one.url}" title="{if !empty($one.description)}{$one.description}{else}{$one.title}{/if}">{$one.title}</a>{else}{$one.title}{/if}
		</li>
		{/foreach}
	</ol>
</nav>
{/strip}
{/if}
