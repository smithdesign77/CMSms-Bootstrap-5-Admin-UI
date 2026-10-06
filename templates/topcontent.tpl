{strip}
<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3 mx-0" id="bs-topcontent">
{foreach from=$nodes item='node' name='box'}
	{assign var='module' value="../modules/`$node.name`/images/icon"}
	{assign var='icon' value="themes/Bootstrap/images/icons/topfiles/`$node.name`"}
	{if $node.show_in_menu && $node.url && $node.title}
	<div class="col">
		<div class="card h-100">
			<div class="card-body">
				<a href="{$node.url}"{if isset($node.target)} target="{$node.target}"{/if} class="d-flex align-items-center text-decoration-none mb-2">
					{if file_exists($module|cat:'.png')}
						<img src="{$module}.png" width="32" height="32" class="me-2" alt="">
					{elseif file_exists($module|cat:'.gif')}
						<img src="{$module}.gif" width="32" height="32" class="me-2" alt="">
					{elseif file_exists($icon|cat:'.png')}
						<img src="{$icon}.png" width="32" height="32" class="me-2" alt="">
					{elseif file_exists($icon|cat:'.gif')}
						<img src="{$icon}.gif" width="32" height="32" class="me-2" alt="">
					{else}
						<img src="themes/Bootstrap/images/icons/topfiles/modules.png" width="32" height="32" class="me-2" alt="">
					{/if}
					<span class="h5 mb-0">{$node.title}</span>
				</a>
				{if $node.description}<p class="card-text small text-muted">{$node.description}</p>{/if}
				{if isset($node.children)}
				<ul class="list-unstyled small mb-0 bs-columns-2">
				{foreach from=$node.children item='one'}
					<li><a href="{$one.url}"{if isset($one.target)} target="{$one.target}"{/if} {if substr($one.url,0,6) == 'logout' and isset($is_sitedown)}onclick="return confirm('{'maintenance_warning'|lang|escape:'javascript'}')"{/if}>{$one.title}</a></li>
				{/foreach}
				</ul>
				{/if}
			</div>
		</div>
	</div>
	{/if}
{/foreach}
</div>
{/strip}
