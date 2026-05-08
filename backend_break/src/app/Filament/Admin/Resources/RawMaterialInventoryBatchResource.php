<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RawMaterialInventoryBatchResource\Pages;
use App\Models\RawMaterialInventoryBatch;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;

class RawMaterialInventoryBatchResource extends Resource
{
    protected static ?string $model = RawMaterialInventoryBatch::class;

    protected static ?string $navigationIcon = 'heroicon-o-archive-box';

    protected static ?string $navigationGroup = 'Inventory';

    protected static ?string $navigationLabel = 'Batch Bahan Baku';

    protected static ?string $modelLabel = 'Batch Bahan Baku';

    protected static ?string $pluralModelLabel = 'Batch Bahan Baku';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Batch')
                    ->schema([
                        Forms\Components\Select::make('raw_material_id')
                            ->label('Bahan Baku')
                            ->relationship('rawMaterial', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(function ($state, callable $set) {
                                $material = \App\Models\RawMaterial::find($state);

                                if ($material) {
                                    $set('uom', $material->uom);
                                }
                            }),

                        Forms\Components\TextInput::make('batch_number')
                            ->label('Nomor Batch')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\DatePicker::make('received_date')
                            ->label('Tanggal Masuk')
                            ->default(now())
                            ->required(),

                        Forms\Components\DatePicker::make('expired_date')
                            ->label('Tanggal Expired')
                            ->required(),

                        Forms\Components\TextInput::make('qty_in')
                            ->label('Qty Masuk')
                            ->numeric()
                            ->required()
                            ->minValue(1)
                            ->reactive()
                            ->afterStateUpdated(function ($state, callable $set, $get) {
                                if (! $get('qty_remaining')) {
                                    $set('qty_remaining', $state);
                                }
                            }),

                        Forms\Components\TextInput::make('qty_remaining')
                            ->label('Qty Tersisa')
                            ->numeric()
                            ->required()
                            ->minValue(0),

                        Forms\Components\TextInput::make('uom')
                            ->label('Satuan')
                            ->readOnly()
                            ->required(),

                        Forms\Components\TextInput::make('supplier')
                            ->label('Supplier')
                            ->maxLength(255),

                        Forms\Components\Textarea::make('notes')
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
                TextColumn::make('rawMaterial.name')
                    ->label('Bahan Baku')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('batch_number')
                    ->label('Batch')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('received_date')
                    ->label('Tanggal Masuk')
                    ->date('d M Y')
                    ->sortable(),

                TextColumn::make('expired_date')
                    ->label('Expired')
                    ->date('d M Y')
                    ->sortable(),

                TextColumn::make('qty_in')
                    ->label('Qty Masuk')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('qty_remaining')
                    ->label('Qty Tersisa')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('uom')
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->getStateUsing(function ($record) {
                        if ($record->qty_remaining <= 0) {
                            return 'Habis';
                        }

                        if ($record->expired_date && $record->expired_date->isPast()) {
                            return 'Expired';
                        }

                        if (
                            $record->expired_date &&
                            now()->lte($record->expired_date) &&
                            now()->diffInDays($record->expired_date) <= 7
                        ) {
                            return 'Hampir Expired';
                        }

                        return 'Aman';
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'Habis' => 'gray',
                        'Expired' => 'danger',
                        'Hampir Expired' => 'warning',
                        'Aman' => 'success',
                        default => 'gray',
                    }),

                TextColumn::make('supplier')
                    ->label('Supplier')
                    ->toggleable(),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('expired_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('raw_material_id')
                    ->label('Bahan Baku')
                    ->relationship('rawMaterial', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Detail'),

                Tables\Actions\EditAction::make()
                    ->label('Edit'),

                Tables\Actions\DeleteAction::make()
                    ->label('Hapus'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRawMaterialInventoryBatches::route('/'),
            'create' => Pages\CreateRawMaterialInventoryBatch::route('/create'),
            'view' => Pages\ViewRawMaterialInventoryBatch::route('/{record}'),
            'edit' => Pages\EditRawMaterialInventoryBatch::route('/{record}/edit'),
        ];
    }
}