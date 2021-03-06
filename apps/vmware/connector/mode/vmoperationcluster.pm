#
# Copyright 2016 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package apps::vmware::connector::mode::vmoperationcluster;

use base qw(centreon::plugins::mode);

use strict;
use warnings;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;
    
    $self->{version} = '1.0';
    $options{options}->add_options(arguments =>
                                {
                                  "cluster:s"               => { name => 'cluster' },
                                  "filter"                  => { name => 'filter' },
                                  "scope-datacenter:s"      => { name => 'scope_datacenter' },
                                  "warning-svmotion:s"      => { name => 'warning_svmotion' },
                                  "critical-svmotion:s"     => { name => 'critical_svmotion' },
                                  "warning-vmotion:s"       => { name => 'warning_vmotion' },
                                  "critical-vmotion:s"      => { name => 'critical_vmotion' },
                                  "warning-clone:s"         => { name => 'warning_clone' },
                                  "critical-clone:s"        => { name => 'critical_clone' },
                                });
    return $self;
}

sub check_options {
    my ($self, %options) = @_;
    $self->SUPER::init(%options);
    
    foreach my $label (('warning_svmotion', 'critical_svmotion', 'warning_vmotion', 'critical_vmotion', 
                        'warning_clone', 'critical_clone')) {
        if (($self->{perfdata}->threshold_validate(label => $label, value => $self->{option_results}->{$label})) == 0) {
            my ($label_opt) = $label;
            $label_opt =~ tr/_/-/;
            $self->{output}->add_option_msg(short_msg => "Wrong " . $label_opt . " threshold '" . $self->{option_results}->{$label} . "'.");
            $self->{output}->option_exit();
        }
    }
}

sub run {
    my ($self, %options) = @_;
    $self->{connector} = $options{custom};

    $self->{connector}->add_params(params => $self->{option_results},
                                   command => 'vmoperationcluster');
    $self->{connector}->run();
}

1;

__END__

=head1 MODE

Check virtual machines operations on cluster(s).

=over 8

=item B<--cluster>

Cluster to check.
If not set, we check all clusters.

=item B<--filter>

Cluster is a regexp.

=item B<--scope-datacenter>

Search in following datacenter(s) (can be a regexp).

=item B<--warning-*>

Threshold warning.
Can be: svmotion, vmotion, clone.

=item B<--critical-*>

Threshold critical.
Can be: svmotion, vmotion, clone.

=back

=cut
