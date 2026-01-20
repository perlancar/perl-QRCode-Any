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
our %argspecopt_format_args = (
    format_args => {
        schema => 'hash*',
        description => <<'MARKDOWN',

Format-specific arguments.

MARKDOWN
    },
);
our %argspecs_format = (
    %argspecopt_format,
    %argspecopt_format_args,
);

our %SPEC;

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
        level => {
            summary => 'Error correction level',
            schema => ['str*', in=>[qw/L M Q H/]],
            default => 'M',
        },
    },
};
sub encode_qrcode {
    my %args = @_;
    my $format = $args{format} // 'png';
    my $level  = $args{level} // 'M';

    if ($format eq 'png') {
        require Imager;
        require Imager::QRCode;
        my $qrcode = Imager::QRCode->new(
            size          => 5,
            margin        => 2,
            version       => 1,
            level         => $level,
            casesensitive => 1,
            lightcolor    => Imager::Color->new(255, 255, 255),
            darkcolor     => Imager::Color->new(0, 0, 0),
        );

        # generates rub-through image
        my $img = $qrcode->plot($args{text});

        my $conv_img = $img->to_rgb8
            or die "converting with to_rgb8() failed: " . Imager->errstr;

        my $filename = $args{filename};
        $filename .= ".png" unless $filename =~ /\.png\z/;
        $conv_img->write(file => $filename)
            or return [500,  "Failed to write to file `$filename`: " . $conv_img->errstr];
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
