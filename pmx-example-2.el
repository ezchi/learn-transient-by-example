
;; need these loaded
(require 'notifications)
(require 'transient)

;; We're going to construct a sentence with a transient.  This is where it's stored.
(defvar ikaruga--toy-sentence "let's transient!"
  "Sentence under construction.")

;; First we define a suffix with a dynamic description.  This allows us to
;; display the current value.  (the transient API could use some more options to
;; display arbitrary values without making a suffix)
;;
;; The interactive form returns a single element list, (SENTENCE) which is then
;; passed into this command.
;;
;; Use transient faces with `propertize' to make your prompts match the feel of
;; other transient behaviors such as switches.
(transient-define-suffix ikaruga-sentence (sentence)
  "Set the sentence from minibuffer read"
  :transient t
  :description '(lambda ()
                  (concat
                   "set sentence: "
                   (propertize
                    (format "%s" ikaruga--toy-sentence)
                    'face 'transient-argument)))
  (interactive (list (read-string "Sentence: " ikaruga--toy-sentence)))
  (setf ikaruga--toy-sentence sentence))

;; Next we define some update commands.  We don't want these commands to dismiss
;; the transient, so we set their `:transient' slot to t for `transient--do-stay'.
;; https://github.com/magit/transient/blob/master/docs/transient.org#transient-state
(transient-define-suffix ikaruga-append-dot ()
  "Append a dot to current sentence"
  :description "append dot"
  :transient t ; true equates to `transient--do-stay'
  (interactive)
  (setf ikaruga--toy-sentence (concat ikaruga--toy-sentence "•")))

(transient-define-suffix ikaruga-append-snowman ()
  "Append a snowman to current sentence"
  :description "append snowman"
  :transient t
  (interactive)
  (setf ikaruga--toy-sentence (concat ikaruga--toy-sentence "☃")))

(transient-define-suffix ikaruga-clear ()
  "Clear current sentence"
  :description "clear"
  :transient t
  (interactive)
  (setf ikaruga--toy-sentence ""))

;; Now we want to consume our sentence.  These commands are the terminal verbs
;; of our sentence construction, so they use the default `transient-do-exit'
;; behavior.
(transient-define-suffix ikaruga-message ()
  "Send the constructed sentence in a message"
  :description "show sentence"
                                        ; :transient nil ; nil is default, `transient--do-exit' behavior
  (interactive)
  (message "constructed sentence: %s" (propertize ikaruga--toy-sentence 'face 'transient-argument))
  (setf ikaruga--toy-sentence ""))

(transient-define-suffix ikaruga-notify ()
  "Notify with constructed sentence"
  :description "notify sentence"
  (interactive)
  (notifications-notify :title "Constructed Sentence:" :body
                        ikaruga--toy-sentence)
  (setf ikaruga--toy-sentence ""))

;; To bind all of our transient commands into a full transient (a "prefix"), we
;; just need group names and key-command pairs.  To put the input sentence onto
;; its own line, we separate the next two groups into their own vector.  You can
;; set the classname key to `transient-columns' or `transient-row' etc for more
;; specific arrangements.
(transient-define-prefix ikaruga-sentence-toy ()
  "Create a sentence with several objects and a verb"
  ["Sentence Toy!"
   ("SPC" ikaruga-sentence)]
  [["Transient Suffixes"
    ("d" ikaruga-append-dot)
    ("s" ikaruga-append-snowman)
    "" ; empty string inserts a gap, visually separating the appends from the clear
    ("c" ikaruga-clear)]
   ["Non-Transient Suffixes"
    ("m" ikaruga-message)
    ("n" ikaruga-notify)]])

(global-set-key (kbd "M-p") 'ikaruga-sentence-toy)
