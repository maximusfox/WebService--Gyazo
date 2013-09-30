package WebService::Gyazo;

use strict;
use warnings;

use WebService::Gyazo::Image;

use LWP::UserAgent;
use LWP::Protocol::socks;
use HTTP::Request::Common;
use URI::Simple;

our $VERSION = 0.01;

use constant {
	HTTP_PROXY => 'http',
	SOCKS4_PROXY => 'socks4',
	SOCKS5_PROXY => 'socks',
	HTTPS_PROXY => 'https',
};

sub new {
	my ($self, %args) = @_;
	$self = bless(\%args, $self);

	return $self;
}

# Получить текст ошибки
sub error {
	my ($self) = @_;
	return ($self->{error}?$self->{error}:'N/A');
}

sub isError {
	my ($self) = @_;
	return ($self->{error}?1:0);
}

# Установить прокси
sub setProxy {
	my ($self, $proxyStr) = @_;
	
	# Если  был передан
	if ($proxyStr) {
		
		#  Выбираем из него ip и port
		#my ($protocol, $ip, $port) = $proxyStr =~ m#(\w+)://(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})#;

		my $proxyUrl = URI::Simple->new($proxyStr);
		my ($protocol, $ip, $port) = ( $proxyUrl->protocol, $proxyUrl->host, ($proxyUrl->port || '80') );
		#print "\n\$protocol=$protocol\n\$ip=$ip\n\$port=$port\n";

		if ( defined($protocol) and defined($ip) and defined($port) ) {
			
			unless ( $protocol eq HTTP_PROXY or $protocol eq HTTPS_PROXY or $protocol eq SOCKS4_PROXY or $protocol eq SOCKS5_PROXY ) {
				$self->{error} = "Wrong protocol type [".$protocol."]";
				return 0;
			}

			# Проверяем правильность введённых значений
			if ( $self->validIp($ip) && $port <= 65535 ) {
				$self->{proxy} = $protocol.'://'.$ip.':'.$port;
				return 1;
			} else {
				$self->{error} = 'Error proxy format!';
				return 0;
			}
		
		# Иначе возращяем отрицание
		} else {
			$self->{proxy} =  'Wrong proxy protocol, ip or port!';
			return 0;
		}
	
	} else {
		# Иначе возвращяем отрицание
		$self->{error} = 'Undefined proxy value!';
		return 0;
	}
}

# Назнначяем ID
sub setId {
	my ($self, $id) = @_;

	# Проверяем длинну ID
	if ( defined($id) and $id =~ m#^\w+$# and length($id) <= 14 ) {
		$self->{id} = $id;
		return 1;
	} else {
		# Иначе возращяем отрицание
		$self->{error} = 'Wrong id syntax!';
		return 0;
	}
}

# Загружаем файл
sub uploadFile {
	my ($self, $file) = @_;

	# Назначаем ID если он не был назначен
	unless ($self->{id}) {
		$self->{id} = time();
	}
	  
	# Проверяем был ли передан путь к файлу
	unless (defined $file) {
		$self->{error} = 'Wrong file location!';
		return 0;
	}
	
	# Проверяем, файл ли это
	unless (-f $file) {
		$self->{error} = 'It\'s not file!';
		return 0;
	}

	# Проверяем возможность считать файл
	unless (-r $file) {
		$self->{error} = 'File not readable!';
		return 0;
	}

	# создаём объект браузера
	$self->{ua} = LWP::UserAgent->new('agent' => 'Gyazo/'.$VERSION) unless (defined $self->{ua});

	# Назначаем прокси если он были передан
	$self->{ua}->proxy(['http'], $self->{proxy}.'/') if ($self->{proxy});

	# создаём объект для POST-запроса
	my $req = POST('http://gyazo.com/upload.cgi',
		'Content_Type' => 'form-data',
		'Content' => [
			'id' => $self->{id},
			'imagedata' => [$file],
		]
	);

	# выполняем POST-запрос и проверяем ответ
	my $res = $self->{ua}->request($req);
	if (my ($id) = ($res->content) =~ m#http://gyazo.com/(\w+)#is) {
		return WebService::Gyazo::Image->new(id => $id);
	} else {
		$self->{error} = "Cent parsed URL in the:\n".$res->as_string."\n";
		return 0;
	}
	
}

__END__



1;