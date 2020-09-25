use strict;
use utf8;
use Storable;
use Getopt::Std;
use Data::Dumper;


binmode STDOUT, ":encoding(utf8)";

my %opts;
getopts('hi:n:s:fT:m:t:F:e:M:p:', \%opts);

my %param;

$param{format}="";
$param{format}=$opts{F} if($opts{F});
die "Unknown format, indicate either Mulan or Meka\n" if($param{format} eq "");


$param{extra}=0;
$param{extra}=$opts{e} if($opts{e});

$param{relFreq}=0;
$param{relFreq}=1 if($opts{f});

$param{maxNgrams}=1;
$param{maxNgrams}=$opts{n} if($opts{n}>1);

$param{maxSkipBigrams}=0;
$param{maxSkipBigrams}=$opts{s} if($opts{s}>0);

$param{mini}=5;
$param{mini}=$opts{m} if($opts{m}>0);

my $dictionarySize;
my %dictionary;

print("\n#########New fold########\n");
print("Preparing file ".$opts{i}."\n");


if($opts{T} ne "")
{
	#We predifine the labels as we needed for the evaluation in Python
	if($opts{T}!~m{NN$})
	{
		$dictionary{LABELS}{"__label__joy"}=0;
		$dictionary{LABELS}{"__label__neutral"}=1;
		$dictionary{LABELS}{"__label__love"}=2;
		$dictionary{LABELS}{"__label__sadness"}=3;
		$dictionary{LABELS}{"__label__anger"}=4;
		$dictionary{LABELS}{"__label__surprise"}=5;
		$dictionary{LABELS}{"__label__fear"}=6;
	}
	else
	{
		$dictionary{LABELS}{"__label__joy"}=0;
		$dictionary{LABELS}{"__label__love"}=1;
		$dictionary{LABELS}{"__label__sadness"}=2;
		$dictionary{LABELS}{"__label__anger"}=3;
		$dictionary{LABELS}{"__label__surprise"}=4;
		$dictionary{LABELS}{"__label__fear"}=5;
	}
	$dictionarySize=keys(%{$dictionary{LABELS}});	#In Mulan the labels have the same shared dictionary
	fitDictionary($opts{i});
	prepareDocuments("Train",$opts{T},$opts{i});
	if($opts{M} ne "" && $opts{p} ne "")
	{
		#print Dumper \%param;
		$dictionary{PARAMS}{relFreq}=$param{relFreq};
		$dictionary{PARAMS}{maxNgrams}=$param{maxNgrams};
		$dictionary{PARAMS}{maxSkipBigrams}=$param{maxSkipBigrams};
		$dictionary{PARAMS}{dictionarySize}=$dictionarySize;
		$dictionary{PARAMS}{extra}=$param{extra};
		saveDict($opts{M}."/".$opts{p}.".dict");
	}
	else
	{
		prepareDocuments("Develop",$opts{T}, $opts{i});
	}
}
elsif($opts{M} ne "" && $opts{p} ne "")
{
	loadDict($opts{M}."/".$opts{p}.".dict");
	$param{relFreq}=$dictionary{PARAMS}{relFreq};
	$param{maxNgrams}=$dictionary{PARAMS}{maxNgrams};
	$param{maxSkipBigrams}=$dictionary{PARAMS}{maxSkipBigrams};
	$param{extra}=$dictionary{PARAMS}{extra};
	$dictionarySize=$dictionary{PARAMS}{dictionarySize};
	delete($param{mini});
	if($opts{t} ne "" && $opts{i} eq "all")
	{
		prepareDocuments("Test", $opts{t}, $opts{i});
	}
}
else
{
	die "No dictionary to work";
}

sub saveDict()
{
	store(\%dictionary, $_[0]);
}
sub loadDict()
{
	%dictionary=%{retrieve($_[0])};
}


sub fitDictionary
{
	my $id=$_[0];
	my $temp;
	my $label;
	my @text;
	my @extra;
	my %document;
	my %temp_dict;
	my $labelCounter=0;

	open(TEXT_IN, '<:utf8', "$ARGV[0]/Train/Train\_$opts{T}\_$id\_text.txt")  or die "$ARGV[0]/Train/Train\_$opts{T}\_$id\_text.txt";

	while(<TEXT_IN>)
	{
		$temp=$_;
		chomp($temp);
		($label, $temp) = split("\t", $temp);
		# unless(exists($dictionary{LABELS}{$label}))
		# {
		# 	$dictionary{LABELS}{$label}=$labelCounter;
		# 	$labelCounter++;
		# }

		$label=$dictionary{LABELS}{$label};
		#print("$temp\n");
		@text=split(" ", $temp);
		%document=%{vectorizerText(\@text, 0)};
		foreach $temp (keys(%document))
		{
			$temp_dict{$temp}++;
		}
	}
	#print Dumper \%temp_dict;
	foreach $temp (keys(%temp_dict))
	{
		if($temp_dict{$temp}>=$param{mini})
		{
			$dictionary{WORDS}{$temp}=$dictionarySize;
			$dictionarySize++;
		}
	}
	close(TEXT_IN);

}

sub prepareDocuments
{
	my $type_file=$_[0];
	my $name=$_[1];
	my $id=$_[2];

	my $temp;
	my $labelTemp;
	my @labels;
	my $label;
	my @text;
	my @extra;
	my %document;
	#Read text file from BastText
	open(TEXT_IN, '<:utf8', "$ARGV[0]/$type_file/$type_file\_$name\_$id\_text.txt")  or die "$ARGV[0]/$type_file/$type_file\_$name\_$id\_text.txt";
	open(EXTRA_IN, '<:utf8', "$ARGV[0]/$type_file/$type_file\_$name\_$id\_extra.txt")  or die "$ARGV[0]/$type_file/$type_file\_$name\_$id\_extra.txt";

	if($param{format} eq "Mulan")
	{
		open(DOC_OUT, '>:utf8', "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Mulan.xml")  or die "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Mulan.xml";
		print(DOC_OUT "<labels xmlns=\"http://mulan.sourceforge.net/labels\">\n");
		foreach $label (keys%{$dictionary{LABELS}})
		{
			print(DOC_OUT "\t<label name=\"$label\"></label>\n");
		}
		print(DOC_OUT "</labels>\n");
		close(DOC_OUT);
		open(DOC_OUT, '>:utf8', "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Mulan.txt")  or die "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Mulan.txt";
	}
	elsif($param{format} eq "Meka")
	{
		open(DOC_OUT, '>:utf8', "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Meka.txt")  or die "$ARGV[1]/$type_file/$type_file\_$name\_$id\_Meka.txt";
	}
	else
	{
		die "$param{format} unknown";
	}

	#Printing Weka header

	#Check if ´ affects the work of Mulan
	print(DOC_OUT "\@RELATION $name\_$id");
	#print(DOC_OUT ": -C ".keys %{$dictionary{LABELS}}) if($param{F} eq "Meka");
	print(DOC_OUT "\n");
	foreach $label (sort{$dictionary{LABELS}{$a} <=> $dictionary{LABELS}{$b}} keys %{$dictionary{LABELS}})
	{
		print(DOC_OUT "\@ATTRIBUTE $label {0, 1}\n");
	}
	#We just print the tokens, but we do not indicate which token is
	for(my $i=0; $i<keys(%{$dictionary{WORDS}}); $i++)
	{
		print(DOC_OUT "\@ATTRIBUTE token$i NUMERIC\n");
	}
	for(my $i=0; $i<$param{extra}; $i++)
	{
		print(DOC_OUT "\@ATTRIBUTE extra$i NUMERIC\n");
	}

	print(DOC_OUT "\@DATA\n");
	while(<TEXT_IN>)
	{
		$temp=$_;
		chomp($temp);
		#Modify to multilabel
		($labelTemp, $temp) = split("\t", $temp);
		@labels=split(" ", $labelTemp);


		@text=split(" ", $temp);
		$temp=<EXTRA_IN>;
		chomp($temp);
		@extra=split(" ", $temp);
		%document=%{vectorizerText(\@text, $param{relFreq})};


		#Printing of the document
		print(DOC_OUT "{");#Sparse format
		my $i=0;
		foreach $labelTemp (sort{$dictionary{LABELS}{$a} <=> $dictionary{LABELS}{$b}} @labels)
		{
			print(DOC_OUT ", ") if($i>0);
			print(DOC_OUT "$dictionary{LABELS}{$labelTemp} 1");
			$i++;
		}

		foreach $temp (keys %document)
		{
			#print("$temp\n");
			unless(exists($dictionary{WORDS}{$temp}))
			{
				delete($document{$temp});
			}
		}

		foreach $temp (sort{$dictionary{WORDS}{$a} <=> $dictionary{WORDS}{$b}} keys %document)
		{
			print(DOC_OUT ", $dictionary{WORDS}{$temp} $document{$temp}");
		}
		#die;
		#print(DOC_OUT "++++");
		for($i=0; $i<@extra; $i++)
		{
			#print($dictionarySize+1+$i."\t$extra[$i]\n");
			if($extra[$i]>0)
			{
				print(DOC_OUT ", ");
				print(DOC_OUT $dictionarySize+$i);
				print(DOC_OUT " $extra[$i]")
			}
		}
		#die;
		print(DOC_OUT "}\n");
	}
	close(TEXT_IN);
	close(EXTRA_IN);
	close(DOC_OUT);

}

sub vectorizerText
{
	my @tokens=@{$_[0]};
	my %document;
	my %ngrams;
	my $token;
	my $documentSize=@tokens;

	foreach my $token (@tokens)
	{
		$document{$token}++;
	}
	if($_[1] && keys(%document)>0)
	{
		foreach $token (keys(%document))
		{
			$document{$token}/=$documentSize;
		}
	}
	if($param{maxNgrams}>1)
	{
		%ngrams=%{ngramGenerator(\@tokens, $_[1])};

		foreach $token (keys(%ngrams))
		{
			$document{$token}=$ngrams{$token};
		}
	}
	if($param{maxSkipBigrams}>0)
	{
		%ngrams=%{skipBigramsGenerator(\@tokens, $_[1])};
		#print Dumper \%ngrams;
		#die;
		foreach $token (keys(%ngrams))
		{
			$document{$token}=$ngrams{$token};
		}
	}
	#print Dumper \%document;
	#die;
	return \%document;

}

sub ngramGenerator
{
	my @tokens=@{$_[0]};
	my $ngram;
	my %temp_ngrams;
	my %ngrams;
	my $total=0;
	for(my $n=2; $n<=$param{maxNgrams}; $n++)
	{
		for(my $i=0; $i<@tokens-($n-1); $i++)
		{
			$ngram="";
			for(my $j=0; $j<$n; $j++)
			{
				$ngram.=$tokens[$i+$j];
				$ngram.=" " if($j!=$n-1);
			}
			if($_[1])
			{
				$temp_ngrams{$ngram}++;
				$total++;
			}
			else
			{
				$ngrams{$ngram}++;
			}
		}
		if($_[1] && $total>0)
		{
			foreach $ngram (keys(%temp_ngrams))
			{
				$ngrams{$ngram}=$temp_ngrams{$ngram}/$total;
			}
			%temp_ngrams={};
			$total=0;
		}
	}
	return \%ngrams;
}

sub skipBigramsGenerator
{
	my @tokens=@{$_[0]};
	my $ngram;
	my %temp_ngrams;
	my %ngrams;
	my $total=0;
	for(my $i=0; $i<=@tokens-1; $i++)
	{
		$ngram="";
		for(my $j=$i+2; $j<$i+$param{maxSkipBigrams}+2; $j++)
		{
			if($j<@tokens)
			{
				$ngram=$tokens[$i]." ".$tokens[$j];
				#print("+++$ngram+++\n");
				if($_[1])
				{
					$temp_ngrams{$ngram}++;
					$total++;
				}
				else
				{
					$ngrams{$ngram}++;
				}
			}
		}
	}
	if($_[1] && $total>0)
	{
		#print Dumper \%temp_ngrams;
		foreach $ngram (keys(%temp_ngrams))
		{
			$ngrams{$ngram}=$temp_ngrams{$ngram}/$total;
		}
		%temp_ngrams={};
		$total=0;
	}
	#print Dumper \%ngrams;
	#die;
	return \%ngrams;
}
