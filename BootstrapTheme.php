<?php
#-------------------------------------------------------------------------
# Bootstrap - a Bootstrap 5 rendering middleware theme for CMS Made Simple
#
# This is NOT a from-scratch admin theme. It is a compatibility layer:
# it re-uses CmsAdminThemeBase (navigation/breadcrumbs/permissions logic,
# unchanged) and, in postprocess(), rewrites the one piece of markup that
# core/modules produce in a JS-framework-specific shape - the
# #page_tabs / #page_content tab structure emitted by cms_admin_tabs -
# into native Bootstrap 5 nav-tabs/tab-content markup.
#
# jQuery UI itself is intentionally left loaded (see js/admin-bridge.js):
# a number of core modules (DesignManager, ModuleManager, FileManager,
# News, CMSContentManager) call $(...).dialog()/.sortable() directly in
# their own templates, independent of this theme. Removing jQuery UI
# would break those modules, which this project explicitly must not
# touch. Only lib/jquery/js/jquery.cms_admin.js is excluded and replaced
# by js/admin-bridge.js, which re-implements the same global API
# (cms_confirm, cms_alert, cms_busy, togglecollapse, cmsms_checkall,
# cmsms_sortable_table) so the ~25 core/module files calling them keep
# working unmodified, while cms_confirm/cms_alert/cmshelp now render as
# Bootstrap modals instead of jQuery UI dialogs.
#
# See ../../../map.md for the full investigation behind this file.
#-------------------------------------------------------------------------

class BootstrapTheme extends CmsAdminThemeBase
{
    private $_errors = [];
    private $_messages = [];

    public function ShowErrors($errors, $get_var = '')
    {
        if ($get_var != '' && isset($_GET[$get_var]) && !empty($_GET[$get_var])) {
            if (is_array($_GET[$get_var])) {
                foreach ($_GET[$get_var] as $one) {
                    $this->_errors[] = lang(cleanValue($one));
                }
            } else {
                $this->_errors[] = lang(cleanValue($_GET[$get_var]));
            }
        } elseif (is_array($errors)) {
            foreach ($errors as $one) {
                $this->_errors[] = $one;
            }
        } elseif (is_string($errors)) {
            $this->_errors[] = $errors;
        }
        return '<!-- BootstrapTheme::ShowErrors() called -->';
    }

    public function ShowMessage($message, $get_var = '')
    {
        if ($get_var != '' && isset($_GET[$get_var]) && !empty($_GET[$get_var])) {
            if (is_array($_GET[$get_var])) {
                foreach ($_GET[$get_var] as $one) {
                    $this->_messages[] = lang(cleanValue($one));
                }
            } else {
                $this->_messages[] = lang(cleanValue($_GET[$get_var]));
            }
        } elseif (is_array($message)) {
            foreach ($message as $one) {
                $this->_messages[] = $one;
            }
        } elseif (is_string($message)) {
            $this->_messages[] = $message;
        }
    }

    public function ShowHeader($title_name, $extra_lang_params = [], $link_text = '', $module_help_type = false)
    {
        if ($title_name) $this->set_value('pagetitle', $title_name);
        if (is_array($extra_lang_params) && count($extra_lang_params)) $this->set_value('extra_lang_params', $extra_lang_params);
        $this->set_value('module_help_type', $module_help_type);

        $config = cms_config::get_instance();

        $module = '';
        if (isset($_REQUEST['module'])) {
            $module = $_REQUEST['module'];
        } elseif (isset($_REQUEST['mact'])) {
            $tmp = explode(',', $_REQUEST['mact']);
            $module = $tmp[0];
        }

        $icon = "modules/{$module}/images/icon.gif";
        $path = cms_join_path($config['root_path'], $icon);
        if (file_exists($path)) {
            $url = $config->smart_root_url() . '/' . $icon;
            $this->set_value('module_icon_url', $url);
        }

        if ($module_help_type) {
            $module_help_url = $this->get_module_help_url();
            $this->set_value('module_help_url', $module_help_url);
        }
    }

    public function do_header()
    {
    }

    public function do_footer()
    {
    }

    public function do_toppage($section_name)
    {
        $smarty = Smarty_CMS::get_instance();
        $otd = $smarty->template_dir;
        $smarty->template_dir = __DIR__ . '/templates';
        if ($section_name) {
            $smarty->assign('section_name', $section_name);
            $smarty->assign('pagetitle', lang($section_name));
            $smarty->assign('nodes', $this->get_navigation_tree($section_name, -1, false));
        } else {
            $nodes = $this->get_navigation_tree(-1, 2, false);
            $smarty->assign('nodes', $nodes);
        }

        $smarty->assign('config', cms_config::get_instance());
        $smarty->assign('theme', $this);

        if (get_site_preference('enablesitedownmessage') == '1') {
            $smarty->assign('is_sitedown', 'true');
        }

        $_contents = $smarty->display('topcontent.tpl');
        $smarty->template_dir = $otd;
        echo $_contents;
    }

    public function do_login($params)
    {
        $config = cms_config::get_instance();
        $smarty = Smarty_CMS::get_instance();

        $smarty->template_dir = __DIR__ . '/templates';
        global $error, $warningLogin, $acceptLogin, $changepwhash;
        $fn = $config['admin_path'] . '/themes/' . $this->themeName . '/login.php';
        include($fn);

        $smarty->assign('lang', get_site_preference('frontendlang'));
        $_contents = $smarty->display('login.tpl');
        return $_contents;
    }

    public function postprocess($html)
    {
        $smarty = Smarty_CMS::get_instance();
        $otd = $smarty->template_dir;
        $smarty->template_dir = __DIR__ . '/templates';
        $module_help_type = $this->get_value('module_help_type');

        $title = $this->get_value('pagetitle');
        $alias = $this->get_value('pagetitle');
        if ($title) {
            if (!$module_help_type) {
                $extra = $this->get_value('extra_lang_params');
                if (!$extra) $extra = [];
                $title = lang($title, $extra);
            }
        } else {
            if ($this->title) {
                $title = $this->title;
            } else {
                $bc = $this->get_breadcrumbs();
                if (is_array($bc) && count($bc)) {
                    $title = $bc[count($bc) - 1]['title'];
                }
            }
        }
        $smarty->assign('pagetitle', $title);
        $smarty->assign('subtitle', $this->subtitle);
        $smarty->assign('pagealias', munge_string_to_url($alias));

        if (($module_name = $this->get_value('module_name'))) {
            $smarty->assign('module_name', $module_name);
        }
        if (($module_icon_url = $this->get_value('module_icon_url'))) {
            $smarty->assign('module_icon_url', $module_icon_url);
        }
        if (!cms_userprefs::get_for_user(get_userid(), 'hide_help_links', 0)) {
            if (($module_help_url = $this->get_value('module_help_url'))) {
                $smarty->assign('module_help_url', $module_help_url);
            }
        }
        if (check_permission(get_userid(), 'Manage My Settings')) {
            $smarty->assign('myaccount', 1);
        }
        if (cms_userprefs::get_for_user(get_userid(), 'bookmarks') && check_permission(get_userid(), 'Manage My Bookmarks')) {
            $marks = $this->get_bookmarks();
            $smarty->assign('marks', $marks);
        }
        $smarty->assign('headertext', $this->get_headtext());
        $smarty->assign('footertext', $this->get_footertext());

        // --- middleware step: rewrite the jQuery-UI-flavoured #page_tabs / #page_content
        // markup that cms_admin_tabs (core) produces into native Bootstrap 5 nav-tabs.
        // See ../../../map.md for why this is scoped narrowly to tabs only.
        $html = $this->bootstrapify_tabs($html);

        $smarty->assign('content', str_replace('</body></html>', '', $html));
        $smarty->assign('config', cms_config::get_instance());
        $smarty->assign('theme', $this);
        $smarty->assign('secureparam', CMS_SECURE_PARAM_NAME . '=' . $_SESSION[CMS_USER_KEY]);
        $userops = UserOperations::get_instance();
        $smarty->assign('user', $userops->LoadUserByID(get_userid()));
        $smarty->assign('lang', cms_userprefs::get_for_user(get_userid(), 'default_cms_language'));
        $lang = CmsNlsOperations::get_current_language();
        $info = CmsNlsOperations::get_language_info($lang);
        $smarty->assign('lang_dir', $info->direction());

        if (is_array($this->_errors) && count($this->_errors)) $smarty->assign('errors', $this->_errors);
        if (is_array($this->_messages) && count($this->_messages)) $smarty->assign('messages', $this->_messages);

        if (get_site_preference('enablesitedownmessage') == '1') {
            $smarty->assign('is_sitedown', 'true');
        }

        $_contents = $smarty->fetch('pagetemplate.tpl');
        $smarty->template_dir = $otd;
        return $_contents;
    }

    public function get_my_alerts()
    {
        return \CMSMS\AdminAlerts\Alert::load_my_alerts();
    }

    /**
     * Rewrite the tab markup produced by lib/classes/class.cms_admin_tabs.php
     * (the only producer of #page_tabs / #page_content in this codebase - see
     * map.md) into Bootstrap 5 nav-tabs / tab-content markup.
     *
     * Deliberate design choice: the tab HEADER block is flat, fixed-shape markup
     * (cms_admin_tabs::set_tab_header() only ever emits
     * <div id="x" class="active"?>Title</div>, never nested tags), so it is safe
     * to parse and rebuild with DOMDocument/DOMXPath. The tab CONTENT panes can
     * contain arbitrary, deeply nested module/WYSIWYG HTML - round-tripping that
     * through DOMDocument risks silently mangling it. So content panes are left
     * byte-for-byte untouched; only their opening <div id="x_c"> tag gets a
     * class="tab-pane ..." attribute spliced in via a targeted, anchored regex.
     */
    private function bootstrapify_tabs($html)
    {
        if (strpos($html, 'id="page_tabs"') === false) return $html;

        if (!preg_match('#<div id="page_tabs">(.*?)</div><!-- EndTabHeaders -->#s', $html, $hm)) {
            return $html;
        }
        $headers_block = $hm[0];
        $headers_inner = $hm[1];

        $dom = new DOMDocument('1.0', 'UTF-8');
        libxml_use_internal_errors(true);
        $dom->loadHTML('<?xml encoding="UTF-8"><div id="_wrap">' . $headers_inner . '</div>', LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
        libxml_clear_errors();
        $xpath = new DOMXPath($dom);
        $tabnodes = $xpath->query('//div[@id="_wrap"]/div');

        if (!$tabnodes || $tabnodes->length === 0) return $html;

        // find the active tab id (cms_admin_tabs guarantees exactly one, server-side)
        $active_id = null;
        foreach ($tabnodes as $node) {
            if (strpos(' ' . $node->getAttribute('class') . ' ', ' active ') !== false) {
                $active_id = $node->getAttribute('id');
                break;
            }
        }
        if ($active_id === null) $active_id = $tabnodes->item(0)->getAttribute('id');

        $navitems = [];
        foreach ($tabnodes as $node) {
            $id = $node->getAttribute('id');
            $is_active = ($id === $active_id);

            $outer = $dom->saveHTML($node);
            $inner = preg_replace('#^<div[^>]*>|</div>\s*$#', '', $outer);

            $navitems[] = sprintf(
                '<li class="nav-item" role="presentation"><button class="nav-link%s" id="%s-tab" data-bs-toggle="tab" data-bs-target="#%s_c" type="button" role="tab" aria-controls="%s_c" aria-selected="%s">%s</button></li>',
                $is_active ? ' active' : '',
                htmlspecialchars($id, ENT_QUOTES),
                htmlspecialchars($id, ENT_QUOTES),
                htmlspecialchars($id, ENT_QUOTES),
                $is_active ? 'true' : 'false',
                $inner
            );
        }

        $new_headers = '<ul class="nav nav-tabs" id="page_tabs" role="tablist">' . implode('', $navitems) . '</ul>';
        $html = str_replace($headers_block, $new_headers, $html);

        // Locate the content block by the exact markers cms_admin_tabs::start_tab_content()/
        // end_tab_content() emit, and edit ONLY inside that substring - the tab panes can
        // contain arbitrary module/WYSIWYG markup, and we must not let the "give this div a
        // tab-pane class" regex below match an unrelated "..._c" id elsewhere on the page.
        $content_open = '<div class="clearb"></div><div id="page_content">';
        $content_close_marker = '<!-- EndTabContent -->';
        $open_pos = strpos($html, $content_open);
        $close_pos = strpos($html, $content_close_marker);
        if ($open_pos === false || $close_pos === false || $close_pos < $open_pos) {
            return $html; // unexpected shape - leave content untouched rather than risk a bad global replace
        }
        $close_pos += strlen($content_close_marker);
        $content_block = substr($html, $open_pos, $close_pos - $open_pos);

        $new_block = str_replace(
            '<div id="page_content">',
            '<div id="page_content" class="tab-content">',
            $content_block
        );
        $new_block = preg_replace_callback(
            '#<div id="([A-Za-z0-9_\-]+_c)">#',
            function ($m) use ($active_id) {
                $is_active = ($m[1] === $active_id . '_c');
                $cls = 'tab-pane fade' . ($is_active ? ' show active' : '');
                return '<div id="' . $m[1] . '" class="' . $cls . '" role="tabpanel">';
            },
            $new_block
        );

        $html = substr($html, 0, $open_pos) . $new_block . substr($html, $close_pos);

        return $html;
    }
}
