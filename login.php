<?php
#-------------------------------------------------------------------------
# Bootstrap - a Bootstrap 5 rendering middleware theme for CMS Made Simple
#-------------------------------------------------------------------------

$gCms = cmsms();
$config = $gCms->GetConfig();
$smarty = $gCms->GetSmarty();

debug_buffer('Debug in the page is: ' . $error);
if (isset($error) && $error != '') {
    $smarty->assign('error', $error);
} elseif (isset($warningLogin) && $warningLogin != '') {
    $smarty->assign('warninglogin', $warningLogin);
} elseif (isset($acceptLogin) && $acceptLogin != '') {
    $smarty->assign('acceptlogin', $acceptLogin);
}

if ($changepwhash != '') {
    $smarty->assign('changepwhash', $changepwhash);
}

$smarty->assign('encoding', get_encoding());
$smarty->assign('config', $gCms->GetConfig());
