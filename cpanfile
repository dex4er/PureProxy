requires 'perl', '5.008001';

requires 'Plack', '0.9920';
requires 'Plack::App::Proxy::Backend::HTTP::Tiny';
requires 'Plack::Middleware::Proxy::Connect::IO';
requires 'Plack::Middleware::Proxy::Requests';
requires 'Thrall', '0.0401';
requires 'Starlight', '0.0501';

recommends 'IO::Socket::IP';
recommends 'Plack::Middleware::TrafficLog';

suggests 'IO::Socket::SSL';
suggests 'Net::SSLeay', '1.49';

on configure => sub {
    requires 'Module::Build';
    requires 'Module::CPANfile';
};

on test => sub {
    requires 'Test::More', '0.88';
};

feature fatpack => sub {
    requires 'parent';
    requires 'App::FatPacker';
    requires 'Exporter';
    requires 'HTTP::Parser';
    requires 'HTTP::Tiny';
    requires 'Time::Local';
};

on develop => sub {
    requires 'Devel::Cover';
    requires 'Devel::NYTProf';
    requires 'File::Slurp';
    requires 'Module::Build';
    requires 'Module::Build::Version';
    requires 'Module::Signature';
    requires 'Perl::Critic';
    requires 'Perl::Critic::Community';
    requires 'Perl::Tidy';
    requires 'Pod::Markdown';
    requires 'Pod::Readme';
    requires 'Readonly';
    requires 'Software::License';
    requires 'Test::CheckChanges';
    requires 'Test::CPAN::Changes';
    requires 'Test::CPAN::Meta';
    requires 'Test::DistManifest';
    requires 'Test::Distribution';
    requires 'Test::EOL';
    requires 'Test::Kwalitee';
    requires 'Test::MinimumVersion';
    requires 'Test::More';
    requires 'Test::NoTabs';
    requires 'Test::Perl::Critic';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
    requires 'Test::PPPort';
    requires 'Test::Signature';
    requires 'Test::Spelling';
};
