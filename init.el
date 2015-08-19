;;; package --- summary

;;; Commentary:

;;; Code:

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)

;; This replaces, rather than appends, on `yank'
(delete-selection-mode)

;; Use MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(defun install-if-not-present (package)
  "Install package (as PACKAGE) if it's not already installed."
  (unless (package-installed-p package)
    (package-install package)))

;; Get list of packages
(install-if-not-present 'cider)
(install-if-not-present 'ac-cider)
(install-if-not-present 'company)
(install-if-not-present 'clj-refactor)
(install-if-not-present 'projectile)
(install-if-not-present 'flx-ido)
;; I can't decide between paredit and smartparens at the moment, so I have both installed.
(install-if-not-present 'smartparens)
(install-if-not-present 'paredit)
(install-if-not-present 'flycheck-clojure)
(install-if-not-present 'flycheck-pos-tip)
(install-if-not-present 'ace-jump-mode)
(install-if-not-present 'base16-theme)
(install-if-not-present 'rainbow-delimiters)
(install-if-not-present 'git-gutter+)
(install-if-not-present 'diminish)
(install-if-not-present 'magit)
(install-if-not-present 'markdown-mode)

;; I want to use Elm
(install-if-not-present 'elm-mode)

;; I want to use SML
(install-if-not-present 'sml-mode)

;; I like paredit in my eval minibuffer
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)

(defun setup-my-global-bindings ()
  "This undefines some key bindings that I find irritating."
  (global-unset-key (kbd "C-z"))
  (define-key global-map [(insert)] nil)
  ;; Ace Jump
  (global-set-key (kbd "C-;") 'ace-jump-word-mode)
  (global-set-key (kbd "C-:") 'ace-jump-line-mode)
  (global-set-key (kbd "C-c b") 'ace-jump-buffer)
  ;; Bookmarks
  (global-set-key (kbd "s-b") 'bookmark-bmenu-list)
  (global-set-key (kbd "s-s") 'bookmark-set)
  ;; Magit status
  (global-set-key (kbd "s-.") 'magit-status)
  ;; Because @ is elsewhere on OS X and I'm trained to hit this to mark sexps
  (global-set-key (kbd "C-M-\"") 'mark-sexp))

(setup-my-global-bindings)

(eval-after-load 'flycheck '(flycheck-clojure-setup))
(add-hook 'after-init-hook #'global-flycheck-mode)
(eval-after-load 'flycheck
                   '(setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages))

(defun my-clojure-mode-setup ()
  "My custom clojure hook."
  (projectile-mode)
  (paredit-mode)
  (rainbow-delimiters-mode)
  (clj-refactor-mode)
    ;; Binding for clj-refactor-mode
  (cljr-add-keybindings-with-prefix "C-c C-m")
  (defvar cider-interactive-eval-result-prefix)
  (setq cider-interactive-eval-result-prefix ";; => ")
  ;; Don't open a buffer for the REPL on connection
  (defvar cider-repl-pop-to-buffer-on-connect)
  (setq cider-repl-pop-to-buffer-on-connect nil)
  ;; dimish changes the text for modes in the modeline.
  (diminish 'projectile-mode "proj")
  (diminish 'cider-mode "cider")
  (diminish 'git-gutter+-mode "GG"))

(add-hook 'clojure-mode-hook #'my-clojure-mode-setup)

(defun my-emacs-lisp-mode-setup ()	;
  "My custom Emacs Lisp mode hook."
  (require 'smartparens-config)
  (smartparens-strict-mode)
  (rainbow-delimiters-mode))

(add-hook 'emacs-lisp-mode-hook #'my-emacs-lisp-mode-setup)

;; Enable flx-ido
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)

(global-auto-complete-mode)

(eval-after-load 'git-gutter+
  '(progn
     ;;; Jump between hunks
     (define-key git-gutter+-mode-map (kbd "C-x n") 'git-gutter+-next-hunk)
     (define-key git-gutter+-mode-map (kbd "C-x p") 'git-gutter+-previous-hunk)

     ;;; Act on hunks
     (define-key git-gutter+-mode-map (kbd "C-x v =") 'git-gutter+-show-hunk)
     (define-key git-gutter+-mode-map (kbd "C-x r") 'git-gutter+-revert-hunks)
     ;; Stage hunk at point.
     ;; If region is active, stage all hunk lines within the region.
     (define-key git-gutter+-mode-map (kbd "C-x t") 'git-gutter+-stage-hunks)
     (define-key git-gutter+-mode-map (kbd "C-x c") 'git-gutter+-commit)
     (define-key git-gutter+-mode-map (kbd "C-x C") 'git-gutter+-stage-and-commit)
     (define-key git-gutter+-mode-map (kbd "C-x C-y") 'git-gutter+-stage-and-commit-whole-buffer)
     (define-key git-gutter+-mode-map (kbd "C-x U") 'git-gutter+-unstage-whole-buffer)))

(global-git-gutter+-mode)

(defun quit-other-window ()
  "Switch to the other window and quit, then switch back."
  (interactive)
  (other-window 1)
  (quit-window 1)
  (other-window 1))

(global-set-key (kbd "s-q") 'quit-other-window)

(defun set-auto-complete-as-completion-at-point-function ()
  "."
  (setq completion-at-point-functions '(auto-complete)))

(add-hook 'cider-repl-mode-hook #'company-mode)
(add-hook 'cider-mode-hook #'company-mode)

;; Remove trailing whitespace before saving the file
(add-hook 'before-save-hook 'whitespace-cleanup)

(custom-set-variables
 '(custom-enabled-themes (quote (base16-tomorrow-dark)))
 '(custom-safe-themes (quote ("75c0b1d2528f1bce72f53344939da57e290aa34bea79f3a1ee19d6808cb55149" default)))
 '(custom-theme-directory "~/.emacs.d/themes/")
 
 '(default-frame-alist (quote ((vertical-scroll-bars)
			       (font . "Inconsolata"))))
 '(sp-base-key-bindings (quote paredit)))

;; I would like to always use y or n, instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; I would always like to save my history
(savehist-mode 1)

;; I have a script that builds a new index.html and opens it in Chrome
(defvar elm-make-command)
(set 'elm-make-command "~/.bin/elm-make-and-show")

;; I like buffers to be auto-reverted if they've changed on disk
(auto-revert-mode)

;;; init.el ends here
