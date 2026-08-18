/** ==========================================================
 * Bootstrap admin theme - compatibility bridge
 *
 * Replacement for lib/jquery/js/jquery.cms_admin.js (excluded via
 * {cms_jquery exclude="cms_admin"} in this theme's templates - see
 * BootstrapTheme.php / map.md for why it has to be a full replacement
 * rather than just "not loaded": a number of core/module templates
 * call cms_confirm()/cms_alert()/cmsms_checkall()/cmsms_sortable_table
 * directly and would break outright if these were simply missing.
 *
 * jQuery UI is still loaded on every admin page (see cms_get_jquery()
 * in lib/functions/misc.functions.php) - it is required by DesignManager,
 * ModuleManager, FileManager, News and CMSContentManager templates, which
 * call $(...).dialog()/.sortable() directly and are out of scope for this
 * theme to modify. Those keep rendering as native jQuery UI widgets.
 * This file only replaces the pieces that jquery.cms_admin.js itself
 * exclusively owned: the global cms_confirm/cms_alert/cms_busy/
 * togglecollapse/cmsms_checkall/cmsms_sortable_table API (kept, but
 * cms_confirm/cms_alert now render as Bootstrap modals), the tab click
 * behaviour (dropped entirely - Bootstrap's own bundle JS drives
 * data-bs-toggle="tab" natively once BootstrapTheme::postprocess() has
 * rewritten the markup), the cmshelp popup (now a Bootstrap modal), and
 * tooltips (now Bootstrap tooltips).
 * ========================================================== */
( function (global, $) {
    'use strict';

    /** ---------------------------------------------------------------
     * cmshelp: click on a `.cms_help img.cms_helpicon` -> ajax-fetch
     * (once) the help text and show it in a shared Bootstrap modal.
     * Markup contract (lib/classes/class.cms_admin_utils.php::get_help_tag()):
     *   <span class="cms_help" data-cmshelp-key="K" data-cmshelp-title="T">
     *     <img class="cms_helpicon" ...>
     *   </span>
     * --------------------------------------------------------------- */
    function ensureHelpModal() {
        var $m = $('#cms-help-modal');
        if ($m.length) return $m;

        $m = $(
            '<div class="modal fade" id="cms-help-modal" tabindex="-1" aria-hidden="true">' +
            '<div class="modal-dialog"><div class="modal-content">' +
            '<div class="modal-header"><h5 class="modal-title"></h5>' +
            '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>' +
            '<div class="modal-body"></div>' +
            '</div></div></div>'
        );
        $('body').append($m);
        return $m;
    }

    function initHelpDialog() {
        $(document).off('click.cmshelp').on('click.cmshelp', '.cms_help img.cms_helpicon', function () {
            var $this = $(this),
                data = $this.parent().data(),
                title = data.cmshelpTitle,
                key = data.cmshelpKey,
                $modal = ensureHelpModal(),
                show = function (html) {
                    $modal.find('.modal-title').text((typeof cms_data !== 'undefined' ? cms_data.title_help + ': ' : '') + title);
                    $modal.find('.modal-body').html(html);
                    bootstrap.Modal.getOrCreateInstance($modal[0]).show();
                };

            if (key && key.length && !$this.data('cmshelp-loaded')) {
                $.get(cms_data.ajax_help_url, { key: key }, function (html) {
                    $this.data('cmshelp-loaded', true).data('cmshelp-html', html);
                    show(html);
                });
            } else {
                show($this.data('cmshelp-html') || '');
            }
        });
    }

    /** ---------------------------------------------------------------
     * Tooltips: Bootstrap tooltips need explicit per-element init.
     * Supports the same three markup conventions the old cms_admin.js did:
     * [title], [data-cms-description], [data-cms-ajax] (fetched once).
     *
     * IMPORTANT: core/module templates (e.g.
     * modules/CMSContentManager/templates/ajax_get_content.tpl) use the
     * literal class "tooltip" as their OWN, pre-existing convention for
     * "this element gets a hover tooltip" - that predates this theme and
     * is baked into ~every content-list row (page title, owner, lock info,
     * etc.). Bootstrap's CSS separately defines `.tooltip { opacity: 0; ... }`
     * as the base style for the popup element IT dynamically creates. Same
     * class name, two unrelated meanings -> left on the trigger element,
     * Bootstrap's rule makes it permanently invisible (not just the popup).
     * Fix: strip the "tooltip" class from the trigger once we've initialised
     * Bootstrap's tooltip on it - Bootstrap's JS instance does not need the
     * class present on the trigger to keep working, only cms-tooltip-ready
     * is needed here to avoid re-initialising it.
     * --------------------------------------------------------------- */
    function initTooltips() {
        $('.tooltip[data-cms-ajax]').each(function () {
            var $el = $(this);
            if ($el.data('cms-tooltip-ready')) return;
            var url = $el.data('cmsAjax') + '&showtemplate=false';
            $.ajax({
                url: url,
                dataType: 'html',
                success: function (content) {
                    $el.attr('data-bs-title', content).data('cms-tooltip-ready', true).removeClass('tooltip');
                    bootstrap.Tooltip.getOrCreateInstance($el[0], { html: true });
                }
            });
        });

        $('.tooltip[data-cms-description]').each(function () {
            var $el = $(this);
            if ($el.data('cms-tooltip-ready')) return;
            $el.attr('data-bs-title', $el.data('cmsDescription')).data('cms-tooltip-ready', true).removeClass('tooltip');
            bootstrap.Tooltip.getOrCreateInstance($el[0], { html: true });
        });

        $('.tooltip[title]').each(function () {
            var $el = $(this);
            if ($el.data('cms-tooltip-ready')) return;
            $el.attr('data-bs-title', $el.attr('title')).removeAttr('title').data('cms-tooltip-ready', true).removeClass('tooltip');
            bootstrap.Tooltip.getOrCreateInstance($el[0]);
        });
    }

    /** ---------------------------------------------------------------
     * Global functions other core/module code depends on directly.
     * Signatures and promise semantics (.done()/.fail()) are kept
     * identical to lib/jquery/js/jquery.cms_admin.js so the ~25 files
     * calling them need no changes. Only the rendering (jQuery UI
     * dialog -> Bootstrap modal) changes.
     * --------------------------------------------------------------- */
    global.togglecollapse = function (cid) {
        $('#' + cid).toggle();
    };

    global.cms_busy = function (flag) {
        if (typeof flag === 'undefined') flag = true;
        var $div = $('#cms_busy');
        if (!$div.length) {
            $div = $('<div/>').attr('id', 'cms_busy').addClass('busy').hide();
            $('body').append($div);
        }
        if (flag) {
            setTimeout(function () { $div.show(); }, 10);
        } else {
            $div.hide();
        }
    };

    global.cms_alert = function (msg, title) {
        var _d = $.Deferred();
        if (typeof msg === 'undefined') return;
        if (typeof title === 'undefined') title = (typeof cms_lang === 'function') ? cms_lang('alert') : 'Alert';

        var $m = $('#cmsms_errorDialog');
        if ($m.length === 0) {
            $m = $(
                '<div class="modal fade" id="cmsms_errorDialog" tabindex="-1" aria-hidden="true">' +
                '<div class="modal-dialog"><div class="modal-content">' +
                '<div class="modal-header"><h5 class="modal-title"></h5>' +
                '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>' +
                '<div class="modal-body"></div>' +
                '<div class="modal-footer"><button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK</button></div>' +
                '</div></div></div>'
            );
            $('body').append($m);
        }
        $m.find('.modal-title').text(title);
        $m.find('.modal-body').html(msg);

        var inst = bootstrap.Modal.getOrCreateInstance($m[0]);
        $m.off('hidden.bs.modal.cmsalert').one('hidden.bs.modal.cmsalert', function () {
            _d.resolve();
        });
        inst.show();

        return _d.promise();
    };

    global.cms_confirm = function (msg, title, yestxt, notxt) {
        var _d = $.Deferred();
        if (typeof msg === 'undefined') return;
        if (typeof title === 'undefined') title = (typeof cms_lang === 'function') ? cms_lang('confirm') : 'Confirm';
        if (typeof yestxt === 'undefined') yestxt = (typeof cms_data !== 'undefined') ? cms_data.lang_yes : 'Yes';
        if (typeof notxt === 'undefined') notxt = (typeof cms_data !== 'undefined') ? cms_data.lang_no : 'No';

        var $m = $('#cmsms_confirmDialog');
        if ($m.length === 0) {
            $m = $(
                '<div class="modal fade" id="cmsms_confirmDialog" tabindex="-1" aria-hidden="true">' +
                '<div class="modal-dialog"><div class="modal-content">' +
                '<div class="modal-header"><h5 class="modal-title"></h5>' +
                '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>' +
                '<div class="modal-body"></div>' +
                '<div class="modal-footer">' +
                '<button type="button" class="btn btn-secondary" data-choice="no">No</button>' +
                '<button type="button" class="btn btn-primary" data-choice="yes">Yes</button>' +
                '</div></div></div></div>'
            );
            $('body').append($m);
        }
        $m.find('.modal-title').text(title);
        $m.find('.modal-body').html(msg);
        $m.find('[data-choice="yes"]').text(yestxt);
        $m.find('[data-choice="no"]').text(notxt);

        var inst = bootstrap.Modal.getOrCreateInstance($m[0]),
            resolved = false;

        $m.off('click.cmsconfirm').on('click.cmsconfirm', '[data-choice]', function () {
            resolved = true;
            var yes = $(this).data('choice') === 'yes';
            inst.hide();
            if (yes) { _d.resolve(yestxt); } else { _d.reject(notxt); }
        });
        $m.off('hidden.bs.modal.cmsconfirm').one('hidden.bs.modal.cmsconfirm', function () {
            if (!resolved) _d.reject(notxt);
        });
        inst.show();

        return _d.promise();
    };

    /** ---------------------------------------------------------------
     * $.fn.cmsms_checkall - "select all" checkbox helper.
     * Framework-agnostic; carried over unchanged.
     * --------------------------------------------------------------- */
    (function ($) {
        var NAME = 'cmsms_checkall', defaults = { target: 'table' };

        function Plugin(element, options) {
            this.element = element;
            this.settings = $.extend({}, defaults, options);
            this._toggle(element, this.settings.target);
        }
        Plugin.prototype._toggle = function (obj, container) {
            var target = $(obj).closest(container), $el = $(obj);

            $('[type=checkbox]', target).not($el).click(function () {
                var $this = $(this), v = $this.prop('checked', !$this.prop('checked'));
                $el.prop('checked', false);
                $this.prop('checked', !$this.prop('checked'));
                $this.trigger('cms_checkall_toggle', { checked: v });
            });

            $el.on('click', function () {
                var v = $el.is(':checked');
                $('[type=checkbox]', target).each(function () {
                    var $this = $(this);
                    $this.attr('checked', v);
                    $this.trigger('cms_checkall_toggle', { checked: v });
                });
            });
        };
        $.fn[NAME] = function (options) {
            return this.each(function () {
                if (!$.data(this, 'plugin_' + NAME)) $.data(this, 'plugin_' + NAME, new Plugin(this, options));
            });
        };
    }(jQuery));

    /** ---------------------------------------------------------------
     * $.widget cmsms.cmsms_sortable_table - unchanged. Requires jQuery UI's
     * sortable widget, which this theme deliberately keeps loaded (see
     * file header comment and map.md).
     * --------------------------------------------------------------- */
    (function ($) {
        if (!$.ui || !$.ui.sortable) return; // jQuery UI not present - nothing to extend
        $.widget('cmsms.cmsms_sortable_table', $.extend({}, $.ui.sortable.prototype, {
            options: { actionurl: null, update: null, helper: null, callback: function () {} },
            _create: function () {
                var self = this;
                this.element.data('sortable', this.element.data('cmsms_sortable_table'));
                this.options.update = function () { self._update(self.options, self.element); };
                this.options.helper = this._uiFixHelper;
                return $.ui.sortable.prototype._create.apply(this, arguments);
            },
            _update: function (options, el) {
                var url = options.actionurl, info = this.serialize($(el));
                $(el).find('tr:even').attr('class', 'row1');
                $(el).find('tr:odd').attr('class', 'row2');
                $.post(url + '&' + info, function (data) { options.callback(data); });
            },
            serialize: function (o) {
                var items = this._getItemsAsjQuery(o && o.connected), str = [];
                o = o || {};
                $(items).each(function () {
                    var res = ($(o.item || this).attr(o.attribute || 'id') || '').match(o.expression || (/(.+)[\-=_](.+)/));
                    if (res) str.push((o.key || res[1] + '[]') + '=' + (o.key && o.expression ? res[1] : res[2]));
                });
                if (!str.length && o.key) str.push(o.key + '=');
                return str.join('&');
            },
            _uiFixHelper: function (e, ui) {
                ui.children().each(function () { $(this).width($(this).width()); });
                return ui;
            }
        }));
        $.cmsms.cmsms_sortable_table.prototype.options = $.extend({}, $.ui.sortable.prototype.options, $.cmsms.cmsms_sortable_table.prototype.options);
    }(jQuery));

    /** ---------------------------------------------------------------
     * Narrow-sidebar toggle (desktop only - see pagetemplate.tpl's
     * #bs-sidebar-narrow-toggle button). Persists via the same localStorage
     * key the pre-paint snippet in pagetemplate.tpl's <head> reads, so the
     * choice survives full page loads (this is a classic multi-page admin,
     * not an SPA) without a flash of the wrong state.
     * --------------------------------------------------------------- */
    $(document).on('click', '#bs-sidebar-narrow-toggle', function () {
        var narrow = document.documentElement.classList.toggle('bs-sidebar-narrow');
        try {
            localStorage.setItem('bs-sidebar-narrow', narrow ? '1' : '0');
        } catch (e) { /* localStorage unavailable (private mode etc.) - just skip persistence */ }
    });

    /** ---------------------------------------------------------------
     * Narrow-mode only: an open top-level submenu now visually overlaps
     * .bs-main (it grows past the 56px icon column, see css/style.css),
     * so clicking elsewhere on the page should dismiss it like any other
     * overlay/dropdown. Only wired to .bs-main, not the whole document -
     * .bs-sidebar-sub is a sibling of .bs-main, not a descendant, so a
     * click on the open menu itself (or its links) never reaches this
     * handler and can't accidentally self-close before navigating.
     * Skipped entirely in wide mode, where the submenu is a normal inline
     * accordion panel, not an overlay - auto-closing it on an unrelated
     * click would be surprising there, not helpful.
     * --------------------------------------------------------------- */
    $(document).on('click', '.bs-main', function () {
        if (!document.documentElement.classList.contains('bs-sidebar-narrow')) return;
        var openSub = document.querySelector('#bs-sidebar-nav .bs-sidebar-sub.show');
        if (openSub) {
            bootstrap.Collapse.getOrCreateInstance(openSub).hide();
        }
    });

    /** ---------------------------------------------------------------
     * "My alerts" dropdown (shortcuts.tpl) - dismiss a single alert via
     * the same ajax endpoint the original OneEleven theme used
     * (cms_data.ajax_alerts_url), without needing the jQuery UI dialog
     * that theme wrapped alerts in.
     * --------------------------------------------------------------- */
    $(document).on('click', '.bs-alert-dismiss', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var $row = $(this).closest('.bs-alert-row'),
            name = $row.data('alertName');
        if (!name || typeof cms_data === 'undefined') { $row.remove(); return; }
        $.post(cms_data.ajax_alerts_url, { op: 'delete', alert: name }).done(function () {
            $row.remove();
        });
    });

    /** ---------------------------------------------------------------
     * Close button on the ajax-apply fly-in (DesignManager's own
     * admin_edit_template.tpl/admin_edit_css.tpl append <aside
     * class="message pagemcontainer/pageerrorcontainer"> straight to
     * <body> and already auto-remove it after 10s - this just lets the
     * "Close" affordance they render actually do something before that).
     * --------------------------------------------------------------- */
    $(document).on('click', 'aside.message .close-warning', function () {
        $(this).closest('aside.message').slideUp(200, function () { $(this).remove(); });
    });

    // No tab-init call here: Bootstrap's bundle JS drives data-bs-toggle="tab" on its
    // own via its data-api once BootstrapTheme::postprocess() has rewritten #page_tabs.
    // No textarea-resize JS either - textarea{resize:vertical} in css/style.css covers
    // it natively in every current browser.
    $(document).ready(function () {
        initHelpDialog();
        initTooltips();

        // See the matching comment in pagetemplate.tpl's <head>: undo the
        // server-forced "active section is open" submenu state once, for
        // real, now that the nav markup exists - then drop the pre-paint
        // CSS override, so every click after this goes through Bootstrap's
        // own collapse toggle with no interference from either of them.
        if (document.documentElement.classList.contains('bs-sidebar-narrow')) {
            document.querySelectorAll('#bs-sidebar-nav > .nav-item > .bs-sidebar-sub.show').forEach(function (sub) {
                sub.classList.remove('show');
                var trigger = document.querySelector('[aria-controls="' + sub.id + '"]');
                if (trigger) trigger.setAttribute('aria-expanded', 'false');
            });
            var presuppress = document.getElementById('bs-sidebar-narrow-presuppress');
            if (presuppress) presuppress.remove();
        }

        $(document).ajaxComplete(function () {
            initTooltips();
        });

        $('form').submit(function (ev) {
            if ($(this).attr('novalidate')) return;
            var total = 0;
            $('input[type=file]', this).each(function (idx, el) {
                if (el.files.length === 0) return;
                total = total + el.files[0].size;
            });
            if (typeof cms_data !== 'undefined' && cms_data.max_upload_size && (total > cms_data.max_upload_size)) {
                alert(cms_data.lang_largeupload);
                return false;
            }
        });
    });

}(this, jQuery));
