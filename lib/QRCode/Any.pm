package QRCode::Any;

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Exporter::Rinci qw(import);

# AUTHORITY
# DATE
# DIST
# VERSION

my $known_formats = [qw/png/]; # TODO: html, txt
my $sch_format = ['str', in=>$known_formats, default=>'png'];
our %argspecopt_format = (
    format => {
        summary => 'Format of QRCode to generate',
        schema => $sch_format,
        description => <<'MARKDOWN',

The default, when left undef, is `png`.

MARKDOWN
        cmdline_aliases => {f=>{}},
    },
);
our %argspecs_format = (
    %argspecopt_format,
    %argspecopt_format_args,
);

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Common interface to QRCode functions',
    description => <<'MARKDOWN',


MARKDOWN
};

$SPEC{'encode_qrcode'} = {
    v => 1.1,
    summary => 'Encode a text into QR Code (in one of several supported formats)',
    description => <<'MARKDOWN',

MARKDOWN
    args => {
        %argspecs_format,
        text => {
            schema => 'str*',
            req => 1,
        },
        filename => {
            schema => 'filename*',
            req => 1,
        },
    },
};
sub encode_qrcode {
    my %args = @_;
    my $format = $args{format} // 'png';

    if ($format eq 'png') {
        require Imager::QRCode;
        my $qrcode = Imager::QRCode->new(
            size          => 2,
            margin        => 2,
            version       => 1,
            level         => 'M',
            casesensitive => 1,
            lightcolor    => Imager::Color->new(255, 255, 255),
            darkcolor     => Imager::Color->new(0, 0, 0),
        );
        my $img = $qrcode->plot("blah blah");
        my $filename = $args{filename};
        $filename .= ".png" unless $filename =~ /\.png\z/;
        $img->write(file => $filename);
            or return [500,  "Failed to write to file `$filename`: " . $img->errstr];
        [200, "OK", undef, {"func.filename"=>$filename}];
    } else {
        [501, "Unsupported format '$format'"];
    }
}

1;
# ABSTRACT:

=head1 DESCRIPTION

This module provides a common interface to QRCode functions.

=cut
