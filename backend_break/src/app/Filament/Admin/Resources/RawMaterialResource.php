<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RawMaterialResource\Pages;
use App\Models\RawMaterial;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;

class RawMaterialResource extends Resource
{
    protected static ?string $model = RawMaterial::class;

    protected static ?string $navigationIcon = 'heroicon-o-cube';

    protected static ?string $navigationGroup = 'Inventory';

    protected static ?string $navigationLabel = 'Raw Materials';

    protected static ?string $modelLabel = 'Raw Material';

    protected static ?string $pluralModelLabel = 'Raw Materials';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Bahan Baku')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nama Bahan')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Select::make('category')
                            ->label('Kategori')
                            ->options([
                                'Bahan Baku' => 'Bahan Baku',
                                'Bahan Tambahan' => 'Bahan Tambahan',
                                'Kemasan' => 'Kemasan',
                            ])
                            ->default('Bahan Baku')
                            ->required(),

                        Forms\Components\TextInput::make('uom')
                            ->label('Satuan (UoM)')
                            ->placeholder('kg / pcs / liter')
                            ->required()
                            ->maxLength(50),

                        Forms\Components\TextInput::make('stock')
                            ->label('Stok Awal')
                            ->numeric()
                            ->default(0)
                            ->required(),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Aktif')
                            ->default(true),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),

                TextColumn::make('name')
                    ->label('Nama Bahan')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('category')
                    ->label('Kategori')
                    ->badge()
                    ->sortable(),

                TextColumn::make('uom')
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('stock')
                    ->label('Stock')
                    ->numeric()
                    ->sortable(),

                IconColumn::make('is_active')
                    ->label('Aktif')
                    ->boolean(),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->filters([
                //
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
            'index' => Pages\ListRawMaterials::route('/'),
            'create' => Pages\CreateRawMaterial::route('/create'),
            'view' => Pages\ViewRawMaterial::route('/{record}'),
            'edit' => Pages\EditRawMaterial::route('/{record}/edit'),
        ];
    }
}