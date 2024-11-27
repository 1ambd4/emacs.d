;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.


;;; Bootstrap config

;; Produce backtraces when errors occur: can be helpful to diagnose startup issues
;;(setq debug-on-error t)

;; Check Emacs version.
(let ((minver "27.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "28.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(defconst *spell-check-support-enable* t)

;; Adjust garbage collection threshold for early startup (see use of gcmh below)
(setq gc-cons-threshold (* 128 1024 1024))

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file)

(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq confirm-kill-emacs #'yes-or-no-p)
(setq org-directory (file-truename "~/org/"))
(electric-pair-mode t)
(column-number-mode t)
(global-auto-revert-mode t)
(delete-selection-mode t)
(global-display-line-numbers-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(savehist-mode nil)
(add-hook 'prog-mode-hook #'hs-minor-mode)
(add-hook 'prog-mode-hook #'show-paren-mode)
(add-to-list 'default-frame-alist '(width . 90))
(add-to-list 'default-frame-alist '(height . 55))


;;; Packages

;; Use USTC Emacs ELPA mirror.
(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")))
(package-initialize)

;; A theme megapack for GNU Emacs.
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-monokai-pro)
  (doom-themes-org-config))

;; Make Emacs bindings that stick around.
(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)

;; Counsel provide versions of common Emacs commands that are customised to make the best use of Ivy.
(use-package counsel
  :ensure t)

;; Ivy is a generic completion mechanism for Emacs.
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffer t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)
   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring)
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

;; Amx is an alternative interface for M-x in Emacs.
(use-package amx
  :ensure t
  :init (amx-mode)
  :config
  (setq amx-save-file (locate-user-emacs-file "data/amx-items")))

;; Quickly switch windows in Emacs.
(use-package ace-window
  :ensure t
  :bind (("C-x o" . 'ace-window)))

;; Move to the beginning/end of line, code or comment.
(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

;; Treat undo history as a tree.
(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode)
  :after hydra
  :bind ("C-x C-h u" . hydra-undo-tree/body)
  :hydra (hydra-undo-tree(:hint nil)
  "
  _p_: undo _n_: redo _s_: save _l_: load"
  ("p" undo-tree-undo)
  ("n" undo-tree-redo)
  ("s" undo-tree-save-history)
  ("l" undo-tree-load-history)
  ("u" undo-tree-visualize "visualize" :color blue)
  ("q" nil "quit" :color blue))
  :custom
  (undo-tree-auto-save-history t)
  (undo-tree-visualizer-diff nil)
  (undo-tree-visualizer-timestamps nil)
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

;; Jump to things in Emacs tree-style.
(global-set-key (kbd "C-j") nil)
(use-package avy
  :ensure t
  :bind
  (("C-j C-SPC" . avy-goto-char-time)))

;; An extensible emacs dashboard.
(use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs!")
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents .5)
			  (bookmarks .5)
			  (projects . 5)))
  (dashboard-setup-startup-hook))

;; Emacs rainbow delimiters mode.
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; Company is a text and code completion framework for Emacs.
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 1)
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0.0)
  (setq company-show-numbers t)
  (setq company-selection-wrap-around t)
  (setq company-transformers '(company-sort-by-occurrence)))

;; Language Server Protocol Support for Emacs.
(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l"
	lsp-file-watch-threshold 500)
  :hook
  (lsp-mode . lsp-enable-which-key-integration)
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-completion-provider :none)
  (setq lsp-headerline-breadcrumb-enable t)
  :bind
  ("C-c l s" . lsp-ivy-workspace-symbol))

;; On the fly syntax checking for GNU Emacs.
(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil)
  :hook
  (prog-mode . flycheck-mode))

;; A Git Porcelain inside Emacs.
(use-package magit
  :ensure t)

;; Project Interaction Library for Emacs.
(use-package projectile
  :ensure t
  :bind (("C-c p" . projectile-command-map))
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-track-known-projects-automaticlly nil))

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :init (counsel-projectile-mode))

;; Tree layout file explorer for Emacs.
(use-package treemacs
  :ensure t
  :defer t
  :config
  (treemacs-tag-follow-mode)
  :bind
  (:map global-map
	("M-0" . treemacs-select-window)
	("C-x t 1" . treemacs-delete-other-windows)
	("C-x t t" . treemacs)))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package lsp-treemacs
  :ensure t
  :after (treemacs lsp))

(provide 'init)
;;; init.el ends here
