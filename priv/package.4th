\ Follows theforth.net publishing guidelines:
\   https://theforth.net/guidelines
forth-package
    key-value name <name>
    key-value version 0.1.0
    key-value license COPL
    key-value description <name>
    key-value main <name>.4th
    \ VitaSound runtime tools (pin to your installed versions)
    key-value fmix ~> 0.7
    key-value flint ~> 0.2
    key-value fcov ~> 0.3
    \ Optional quality gate config (fmix check reads these when uncommented):
    \ key-list fmix-check-pre-commit test flint
    \ key-list fmix-check-pre-push test flint fcov
    \ key-value fcov-fail-under 40
    key-list tags gforth
    key-list dependencies fsemver git https://github.com/VitaSound/fsemver tag 0.1.0
    key-list dependencies fenum git https://github.com/VitaSound/fenum tag 0.1.1
    key-list dependencies ttester git https://github.com/VitaSound/ttester tag 1.2.1
    key-list dependencies f git https://github.com/VitaSound/f tag 0.2.4
end-forth-package
