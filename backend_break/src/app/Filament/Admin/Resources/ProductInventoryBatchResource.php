<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ProductInventoryBatchResource\Pages;
use App\Models\ProductInventoryBatch;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class ProductInventoryBatchResource extends Resource
{
    protected static ?string $model =
        ProductInventoryBatch::class;

    protected static ?string $navigationIcon ='heroicon-o-cube';
    protected static ?string $navigationGroup ='Inventory Produk';
    protected static ?string $navigationLabel ='Batch Produk';
    protected static ?string $modelLabel ='Batch Produk';
    protected static ?string $pluralModelLabel ='Batch Produk';
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([

                Forms\Components\Section::make(
                    'Informasi Batch Produk'
                )
                    ->schema([

                        Forms\Components\Select::make(
                            'product_id'
                        )
                            ->label('Produk')
                            ->relationship(
                                'product',
                                'name'
                            )
                            ->searchable()
                            ->preload()
                            ->required(),

                        Forms\Components\TextInput::make(
                            'batch_number'
                        )
                            ->label('Nomor Batch')
                            ->required()
                            ->unique(
                                ignoreRecord: true
                            ),

                        Forms\Components\DatePicker::make(
                            'production_date'
                        )
                            ->label(
                                'Tanggal Produksi'
                            )
                            ->required(),

                        Forms\Components\DatePicker::make(
                            'expired_date'
                        )
                            ->label(
                                'Tanggal Expired'
                            )
                            ->required(),

                        Forms\Components\TextInput::make(
                            'qty_in'
                        )
                            ->label('Qty Masuk')
                            ->numeric()
                            ->required(),

                        Forms\Components\TextInput::make(
                            'qty_remaining'
                        )
                            ->label(
                                'Qty Tersisa'
                            )
                            ->numeric()
                            ->required(),

                        Forms\Components\TextInput::make(
                            'uom'
                        )
                            ->label('Satuan')
                            ->required(),

                        Forms\Components\Textarea::make(
                            'notes'
                        )
                            ->label('Catatan')
                            ->rows(3)
                            ->columnSpanFull(),

                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([

                TextColumn::make(
                    'product.name'
                )
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),

                TextColumn::make(
                    'batch_number'
                )
                    ->label('Batch')
                    ->searchable(),

                TextColumn::make(
                    'production_date'
                )
                    ->label('Produksi')
                    ->date('d M Y'),

                TextColumn::make(
                    'expired_date'
                )
                    ->label('Expired')
                    ->date('d M Y'),

                TextColumn::make(
                    'qty_in'
                )
                    ->label('Qty Masuk'),

                TextColumn::make(
                    'qty_remaining'
                )
                    ->label('Qty Tersisa'),

                TextColumn::make(
                    'uom'
                )
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->getStateUsing(function (
                        $record
                    ) {

                        if (
                            $record->qty_remaining <= 0
                        ) {
                            return 'Habis';
                        }

                        if (
                            $record->expired_date &&
                            $record->expired_date->isPast()
                        ) {
                            return 'Expired';
                        }

                        if (
                            $record->expired_date &&
                            now()->diffInDays(
                                $record->expired_date
                            ) <= 3
                        ) {
                            return 'Hampir Expired';
                        }

                        return 'Aman';
                    })
                    ->color(fn (
                        string $state
                    ): string => match ($state) {

                        'Habis' => 'gray',
                        'Expired' => 'danger',
                        'Hampir Expired' => 'warning',
                        'Aman' => 'success',

                        default => 'gray',
                    }),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i'),
            ])
            ->defaultSort(
                'expired_date',
                'asc'
            )
            ->actions([

                Tables\Actions\ViewAction::make(),

                Tables\Actions\EditAction::make(),

            ]);
    }

    public static function getPages(): array
    {
        return [

            'index' =>
                Pages\ListProductInventoryBatches::route('/'),

            'create' =>
                Pages\CreateProductInventoryBatch::route('/create'),

            'view' =>
                Pages\ViewProductInventoryBatch::route('/{record}'),

            'edit' =>
                Pages\EditProductInventoryBatch::route('/{record}/edit'),
        ];
    }
}