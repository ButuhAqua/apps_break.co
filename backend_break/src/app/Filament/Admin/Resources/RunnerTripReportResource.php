<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RunnerTripReportResource\Pages;
use App\Models\RunnerTripReport;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class RunnerTripReportResource extends Resource
{
    protected static ?string $model = RunnerTripReport::class;

    protected static ?string $navigationIcon = 'heroicon-o-truck';
    protected static ?string $navigationGroup ='Operasional Runner';
    protected static ?string $navigationLabel = 'Laporan Trip Runner';
    protected static ?string $modelLabel = 'Laporan Trip Runner';
    protected static ?string $pluralModelLabel = 'Laporan Trip Runner';
    protected static ?int $navigationSort = 11;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Informasi Trip')
                ->schema([
                    Forms\Components\Select::make('user_id')
                        ->label('Runner')
                        ->relationship('user', 'name')
                        ->searchable()
                        ->preload()
                        ->required(),

                    Forms\Components\Select::make('location')
                        ->label('Gerobak')
                        ->options([
                            'Gerobak A' => 'Gerobak A',
                            'Gerobak B' => 'Gerobak B',
                        ])
                        ->required(),

                    Forms\Components\DateTimePicker::make('departure_at')
                        ->label('Waktu Berangkat'),

                    Forms\Components\DateTimePicker::make('return_at')
                        ->label('Waktu Pulang'),

                    Forms\Components\Select::make('status')
                        ->label('Status')
                        ->options([
                            'ONGOING' => 'Sedang Berjalan',
                            'FINISHED' => 'Selesai',
                        ])
                        ->default('ONGOING')
                        ->required(),

                    Forms\Components\Textarea::make('notes')
                        ->label('Catatan')
                        ->rows(3)
                        ->columnSpanFull(),
                ])
                ->columns(2),

            Forms\Components\Section::make('Produk Dibawa')
                ->schema([
                    Forms\Components\Repeater::make('items')
                        ->relationship()
                        ->schema([
                            Forms\Components\Select::make('product_id')
                                ->label('Produk')
                                ->relationship('product', 'name')
                                ->searchable()
                                ->preload()
                                ->required(),

                            Forms\Components\TextInput::make('qty_taken')
                                ->label('Qty Dibawa')
                                ->numeric()
                                ->required()
                                ->minValue(1),

                            Forms\Components\TextInput::make('qty_returned')
                                ->label('Qty Kembali')
                                ->numeric()
                                ->minValue(0),

                            Forms\Components\TextInput::make('qty_sold')
                                ->label('Qty Terjual')
                                ->numeric()
                                ->default(0)
                                ->minValue(0),

                            Forms\Components\TextInput::make('uom')
                                ->label('Satuan')
                                ->required(),
                        ])
                        ->columns(5)
                        ->columnSpanFull(),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Runner')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('location')
                    ->label('Gerobak')
                    ->badge()
                    ->sortable(),

                TextColumn::make('departure_at')
                    ->label('Berangkat')
                    ->dateTime('d M Y H:i')
                    ->sortable(),

                TextColumn::make('return_at')
                    ->label('Pulang')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->placeholder('-'),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'ONGOING' => 'info',
                        'FINISHED' => 'success',
                        default => 'gray',
                    }),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make()->label('Detail'),
                Tables\Actions\EditAction::make()->label('Edit'),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRunnerTripReports::route('/'),
            'create' => Pages\CreateRunnerTripReport::route('/create'),
            'view' => Pages\ViewRunnerTripReport::route('/{record}'),
            'edit' => Pages\EditRunnerTripReport::route('/{record}/edit'),
        ];
    }
}