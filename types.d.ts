/*
 *  Name: types.d.ts
 *  From @rbxts/trello
 *
 *  Description: Typings for @rbxts/trello NPM package.
 *
 *  Copyright (c) 2019 David Duque.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 */

/**
 *  Represents a Trello Account. Trello Entities are used to hold the API authentication string and to assign boards to.
 *  You can create and handle more than one TrelloClient at a given time, effectively controlling more than two accounts at the same time.
 */
interface Client {
    /** The username associated with the Trello account being managed by this TrelloClient. */
    readonly User: string | undefined;

    GetBoards(): Promise<Array<Board>>;

    /**
     * @yields Gets all boards in a given client. Boards are not deeply loaded.
     *
     * @returns An array containing zero or more Trello boards.
     */
    AwaitGetBoards(): Array<Board>;

    GetBoard(remoteId: string): Promise<Board | undefined>;

    AwaitGetBoard(remoteId: string): Board | undefined;
}

interface TrelloClientConstructor {
    /**
     * @constructor Creates a new TrelloClient, that represents a Trello account.
     *
     * @param key Your developer key. Cannot be empty or undefined.
     * @param token Your developer token. Optional if you're only READING from a PUBLIC board.
     *
     * @returns A promise that resolves to a client when available.
     */
    new (key: string, token?: string | undefined): Promise<Client>;

    /**
     * @constructor @yields Creates a new TrelloClient, that represents a Trello account.
     *
     * @param key Your developer key. Cannot be empty or undefined.
     * @param token Your developer token. Optional if you're only READING from a PUBLIC board.
     * @param throwOnFailure Whether an error should be thrown (instead of a warning) if key validation fails.
     *
     * @returns A client object. If 'throwOnFailure` is false, the constructor might return `undefined` if key validation fails
     */
    readonly awaitNew: <Err extends boolean>(
        key: string,
        token?: string | undefined,
        throwOnFailure?: Err
    ) => Err extends true ? Client : Client | undefined;
}

// Trello Entities
interface Entity {
    readonly RemoteId: string;
    readonly Client: Client;
    Name: string;

    /**
     * Pushes all metadata changes to Trello. (Doesn't apply to subentities.)
     *
     * @param force Whether to push all changes to Trello even though nothing has been changed.
     *
     * @returns A promise that resolves when the changes are applied.
     */
    Push(force?: boolean): Promise<void>;

    /**
     * @yields Pushes all metadata changes to Trello. (Doesn't apply to subentities.)
     *
     * @param force Whether to push all changes to Trello even though nothing has been changed.
     */
    AwaitPush(force?: boolean): void;

    /**
     * Force-pulls the most recent board metadata from Trello (Doesn't apply to subentities.)
     *
     * @returns Promise that resolves on update
     */
    Pull(): Promise<void>;

    /**
     * @yields Force-pulls the most recent board metadata from Trello (Doesn't apply to subentities.)
     */
    AwaitPull(): void;

    /**
     * Deletes this entity (and subentities) from Trello.
     *
     * @returns A promise that resolves when thee board is gone for good.
     */
    Delete(): Promise<void>;

    /**
     * @yields Deletes this entity (and subentities) from Trello.
     */
    AwaitDelete(): void;
}

interface Board extends Entity {
    readonly DeepLoaded: boolean;
    Description: string;
    Public: boolean;
    Closed: boolean;

    /**
     * Deeploads the board (everything from it is requested)
     *
     * @returns A promise that is resolved when the deep load operation finishes.
     */
    DeepLoad(): Promise<void>;

    /**
     * @yields Deep-loads the board (so that it contains lists, cards, etc.)
     */
    AwaitDeepLoad(): void;

    /**
     * Returns the board's lists. Returns undefined if the board is not deep-loaded yet.
     */
    GetLists(): Array<List> | undefined;

    /**
     * Returns a list with the given id.
     * Returns undefined is the board is not deep-loaded or if the list doesn't exist within the board.
     */
    GetList(id: string): List | undefined;
}

interface TrelloBoardConstructor {
    /**
     * @constructor @yields Creates a new Trello board, that is then also created on Trello.
     *
     * @param name The Board's name. Must to be a non-empty string with a maximum of 16384 characters.
     * @param public Whether the new board should be public or not. If this field is not provided, the board will be private.
     * @param client The entity the board will be assigned to.
     *
     * @returns A new TrelloBoard that was freshly created.
     */
    new (name: string, public: boolean, client: Client): Promise<Board>;

    /**
     * @constructor @yields Creates a new Trello board, that is then also created on Trello.
     *
     * @param name The Board's name. Must to be a non-empty string with a maximum of 16384 characters.
     * @param public Whether the new board should be public or not. If this field is not provided, the board will be private.
     * @param client The entity the board will be assigned to.
     *
     * @returns A brand new, freshly created Trello Board.
     */
    readonly awaitNew: (name: string, public: boolean, entity: Client) => Board;
}

// Unimplemented interfaces
interface List extends Entity {
    Board: Board;
    Archived: boolean;
}

interface TrelloListConstructor {
    /**
     * @constructor @yields Creates a new Trello list and appends it to the given board.
     */
    new (title: string, board: Board): List;
}

interface Card extends Entity {
    List: List;
    Archived: boolean;
    Description: string;
    Labels: Array<Label>;

    Comment(comment: string): void;
    AssignLabels(label: Array<Label>): void;
}

interface TrelloCardConstructor {
    /**
     * @constructor @yields Creates a new Trello board and appends it to the bottom of the given list.
     */
    new (name: string, description: string, list: List): Card;
}

interface LabelColor {
    readonly None: string;
    readonly Black: string;
    readonly Red: string;
    readonly Orange: string;
    readonly Yellow: string;
    readonly LimeGreen: string;
    readonly Green: string;
    readonly SkyBlue: string;
    readonly Blue: string;
    readonly Purple: string;
    readonly Pink: string;
}

interface Label extends Entity {
    readonly Board: Board;
    color: LabelColor;
}

interface TrelloLabelConstructor {
    new (name: string, color: LabelColor, board: Board): Label;
}

declare const Client: TrelloClientConstructor;
declare const Board: TrelloBoardConstructor;
declare const List: TrelloListConstructor;
declare const Card: TrelloCardConstructor;
declare const Label: TrelloLabelConstructor;

export { Client, Board, Label, LabelColor };
