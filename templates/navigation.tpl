{strip}
{if !isset($depth)}{assign var='depth' value=0}{/if}
{if $depth == 0}
<ul class="nav flex-column bs-sidebar-nav" id="bs-sidebar-nav">
{/if}
{if $depth == 0}
	{assign var='topicon' value='themes/Bootstrap/images/icons/topfiles/'}
{/if}
{foreach from=$nav item='navitem' name='pos'}
	{if isset($navitem.children)}
		{assign var='subid' value="bsnav-`$navitem.name`"}
		<li class="nav-item">
			<a class="nav-link d-flex align-items-center{if !empty($navitem.selected)} active{/if}" href="#{$subid}" data-bs-toggle="collapse" role="button" aria-expanded="{if !empty($navitem.selected)}true{else}false{/if}" aria-controls="{$subid}" title="{$navitem.title|strip_tags}">
				{if $depth == 0}
					{if file_exists($topicon|cat:$navitem.name|cat:'.png')}
						<img src="{$topicon}{$navitem.name}.png" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{elseif file_exists($topicon|cat:$navitem.name|cat:'.gif')}
						<img src="{$topicon}{$navitem.name}.gif" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{else}
						<img src="{$topicon}modules.png" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{/if}
				{/if}
				<span class="bs-nav-label">{$navitem.title}</span>
				<span class="bs-nav-caret ms-auto">&#9662;</span>
			</a>
			<ul class="collapse nav flex-column bs-sidebar-sub{if !empty($navitem.selected)} show{/if}" id="{$subid}"{if $depth == 0} data-bs-parent="#bs-sidebar-nav"{/if}>
				{include file='navigation.tpl' nav=$navitem.children depth=$depth+1}
			</ul>
		</li>
	{else}
		<li class="nav-item">
			<a class="nav-link d-flex align-items-center{if !empty($navitem.selected)} active{/if}" href="{$navitem.url}"{if isset($navitem.target)} target="_blank"{/if} title="{if !empty($navitem.description)}{$navitem.description|strip_tags}{else}{$navitem.title|strip_tags}{/if}" {if substr($navitem.url,0,6) == 'logout' and isset($is_sitedown)}onclick="return confirm('{'maintenance_warning'|lang|escape:'javascript'}')"{/if}>
				{if $depth == 0}
					{if file_exists($topicon|cat:$navitem.name|cat:'.png')}
						<img src="{$topicon}{$navitem.name}.png" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{elseif file_exists($topicon|cat:$navitem.name|cat:'.gif')}
						<img src="{$topicon}{$navitem.name}.gif" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{else}
						<img src="{$topicon}modules.png" width="20" height="20" class="bs-nav-icon me-2" alt="">
					{/if}
				{/if}
				<span class="bs-nav-label">{$navitem.title}</span>
			</a>
		</li>
	{/if}
{/foreach}
{if $depth == 0}
</ul>
{/if}
{/strip}
