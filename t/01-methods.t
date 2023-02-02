#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

my $module = 'Music::Chord::Progression::Transform';

use_ok $module;

subtest throws => sub {
    throws_ok { $module->new(base_note => 'I') }
        qr/not a valid note/, 'bogus base_note';

    throws_ok { $module->new(base_octave => -1) }
        qr/not a valid octave/, 'bogus base_octave';

    throws_ok { $module->new(format => 'foo') }
        qr/not a valid format/, 'bogus format';

    throws_ok { $module->new(max => -1) }
        qr/not a valid maximum/, 'bogus max';

    throws_ok { $module->new(semitones => -1) }
        qr/not a valid number of semitones/, 'bogus semitone';

    throws_ok { $module->new(allowed => 'foo') }
        qr/not valid/, 'bogus allowed';

    throws_ok { $module->new(transforms => 'foo') }
        qr/not a valid transform/, 'bogus transform';

    throws_ok { $module->new(transforms => {}) }
        qr/not a valid transform/, 'bogus transform';
};

subtest default => sub {
    my $obj = new_ok $module;
    my $got = $obj->generate;
    my $expect = 4;
    is @$got, $expect, "generated $expect chords";
    $expect = [qw(C4 E4 G4)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

subtest transform_array => sub {
    my $obj = new_ok $module => [
        transforms => [qw(O P T2)],
    ];
    my $got = $obj->generate;
    no warnings qw(qw);
    my $expect = [[qw(C4 E4 G4)], [qw(C4 D#4 G4)], [qw(D4 F4 A4)]];
    is_deeply $got, $expect, 'generated chords';
};

subtest transform_integer => sub {
    my $expect = 3;
    my $obj = new_ok $module => [
        transforms => $expect,
    ];
    my $got = $obj->generate;
    is @$got, $expect, "generated $expect chords";
    $expect = [qw(C4 E4 G4)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

subtest transform_base => sub {
    my $obj = new_ok $module => [
        base_note   => 'G',
        base_octave => 5,
    ];
    my $got = $obj->generate;
    my $expect = 4;
    is @$got, $expect, "generated $expect chords";
    $expect = [qw(G5 B5 D6)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

subtest midinum_format => sub {
    my $obj = new_ok $module => [
        format => 'midinum',
    ];
    my $got = $obj->generate;
    my $expect = [qw(60 64 67)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

subtest circular => sub {
    my $expect = 4;
    my $obj = new_ok $module => [
        transforms => [qw(I P T2)],
        max        => $expect,
    ];
    my $got = $obj->circular;
    is @$got, $expect, "generated $expect chords";
    $expect = [qw(C4 E4 G4)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

subtest quality => sub {
    my $obj = new_ok $module => [
        chord_quality => '7',
        transforms    => [qw(I T1 T2 T3)],
    ];
    my $got = $obj->generate;
    my $expect = 4;
    is @$got, $expect, "generated $expect chords";
    no warnings qw(qw);
    $expect = [qw(C4 E4 G4 A#4)];
    is_deeply $got->[0], $expect, 'generated 0th chord';
};

done_testing();
