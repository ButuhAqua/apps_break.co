<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\EmployeeResource\Pages;
use App\Models\Employee;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class EmployeeResource extends Resource
{
    protected static ?string $model = Employee::class;

    protected static ?string $navigationIcon = 'heroicon-o-identification';
    protected static ?string $navigationGroup = 'Administration';
    protected static ?string $navigationLabel = 'Employees';
    protected static ?string $modelLabel = 'Employee';
    protected static ?string $pluralModelLabel = 'Employees';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Data Employee')
                ->schema([
                    Forms\Components\Select::make('user_id')
                        ->label('Akun User')
                        ->relationship('user', 'name')
                        ->searchable()
                        ->preload()
                        ->required()
                        ->unique(ignoreRecord: true),

                    Forms\Components\TextInput::make('employee_code')
                        ->label('Kode Employee')
                        ->default(fn () => 'EMP-' . now()->format('YmdHis'))
                        ->required()
                        ->unique(ignoreRecord: true)
                        ->maxLength(255),

                    Forms\Components\TextInput::make('full_name')
                        ->label('Nama Lengkap')
                        ->required()
                        ->maxLength(255),

                    Forms\Components\Select::make('role')
                        ->label('Role Operasional')
                        ->options([
                            'Admin' => 'Admin',
                            'Owner' => 'Owner',
                            'Manager' => 'Manager',
                            'Unit Produksi' => 'Unit Produksi',
                            'Runner' => 'Runner',
                        ])
                        ->required()
                        ->reactive(),

                    Forms\Components\Select::make('assigned_location')
                        ->label('Penempatan')
                        ->options([
                            'Basecamp' => 'Basecamp',
                            'Gerobak A' => 'Gerobak A',
                            'Gerobak B' => 'Gerobak B',
                        ])
                        ->nullable()
                        ->helperText('Untuk Runner wajib isi gerobak. Unit produksi biasanya Basecamp.'),

                    Forms\Components\Select::make('status')
                        ->label('Status')
                        ->options([
                            'Aktif' => 'Aktif',
                            'Nonaktif' => 'Nonaktif',
                        ])
                        ->default('Aktif')
                        ->required(),
                ])
                ->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('employee_code')
                    ->label('Kode')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('full_name')
                    ->label('Nama')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.email')
                    ->label('Email')
                    ->searchable(),

                Tables\Columns\TextColumn::make('role')
                    ->label('Role')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('assigned_location')
                    ->label('Penempatan')
                    ->badge()
                    ->default('-')
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Aktif' => 'success',
                        'Nonaktif' => 'danger',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->label('Role')
                    ->options([
                        'Admin' => 'Admin',
                        'Owner' => 'Owner',
                        'Manager' => 'Manager',
                        'Unit Produksi' => 'Unit Produksi',
                        'Runner' => 'Runner',
                    ]),

                Tables\Filters\SelectFilter::make('assigned_location')
                    ->label('Penempatan')
                    ->options([
                        'Basecamp' => 'Basecamp',
                        'Gerobak A' => 'Gerobak A',
                        'Gerobak B' => 'Gerobak B',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListEmployees::route('/'),
            'create' => Pages\CreateEmployee::route('/create'),
            'edit' => Pages\EditEmployee::route('/{record}/edit'),
        ];
    }
}