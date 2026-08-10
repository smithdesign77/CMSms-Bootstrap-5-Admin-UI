{strip}
{if isset($errors) && $errors[0] != ''}
<div class="alert alert-danger alert-dismissible fade show" role="alert">
	{foreach from=$errors item='error'}{if $error}<div>{$error}</div>{/if}{/foreach}
	<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
{/if}
{if isset($messages) && $messages[0] != ''}
<div class="alert alert-success alert-dismissible fade show" role="alert">
	{foreach from=$messages item='message'}{if $message}<div>{$message}</div>{/if}{/foreach}
	<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
{/if}
{/strip}
