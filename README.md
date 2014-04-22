# NAME

Pod::Perldoc::Cache - Caching perldoc output for quick reference

# SYNOPSIS

    perldoc -MPod::Perldoc::Cache CGI
    perldoc -MPod::Perldoc::Cache -w parser=Pod::Text::Color::Delight CGI

# DESCRIPTION

Pod::Perldoc::Cache caches the formatted output from perldoc command and references it for the second time. Once the cache file is generated, perldoc command no more formats the pod file, but replies the cache content instantly.

# OPTIONS AND CONFIGURATION

- -w parser=Parser::Module

    With "-w parser" option, you can specify the parser(formatter) module for perldoc which is used when the cache file doesn't exist.

- -w ignore

    If "-w ignore" option is given, the cache file is ignored and pod file is re-rendered.

# SEE ALSO

[Pod::Text](https://metacpan.org/pod/Pod::Text)
[Pod::Text::Color::Delight](https://metacpan.org/pod/Pod::Text::Color::Delight)

# LICENSE

Copyright (C) Yuuki Furuyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Yuuki Furuyama <addsict@gmail.com>
