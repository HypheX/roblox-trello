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
    /** The authentication string that is appended at the end of the API URL's. DO NOT EXPOSE THIS STRING TO THE CLIENT! */
    readonly Auth: string;

    /** The username associated with the Trello account being managed by this TrelloClient. */
    readonly User: string | undefined;

    /**
     *  Creates a syntactically correct URL for use within the module. Authentication is automatically appended.
     *
     *  @param page The page that you wish to request to. Base URL is https://api.trello.com/1/ (page cannot be empty). Example: "/batch"
     *  @param queryParams A map containing any parameters you wish to pass. Example: {urls: ["/members", "/boards"]}
     *
     *  @returns A URL you can make requests to.
     */
    MakeURL(
        page: string,
        queryParams?: Map<string, string | boolean | number | Array<string> | Map<string, string | boolean | number>>,
    ): string;
}

interface TrelloClientConstructor {
    /**
     *  @constructor @yields Creates a new TrelloClient, that represents a Trello account.
     *
     *  @param key Your developer key. Cannot be empty or undefined.
     *  @param token Your developer token. Optional if you're only READING from a PUBLIC board.
     *  @param errorOnFailure Whether an error should be thrown (instead of a warning) if key validation fails.
     *
     *  @returns a client object. If 'errorOnFailure` is false, the constructor might return `undefined` if key validation fails
     */
    new <Err extends boolean>(key: string, token?: string | undefined, errorOnFailure?: Err): Err extends true
        ? Client
        : Client | undefined;
}

// Trello Entities
interface Entity {
    readonly RemoteId: string;
    readonly Loaded: boolean;
    readonly Client: Client;
    Name: string;

    /**
     *  Pushes all metadata changes to Trello. (Doesn't apply to subentities.)
     *
     *  @param force Whether to push all changes to Trello even though nothing has been changed.
     */
    Update(force?: boolean): void;

    /**
     *  Deletes this entity (and subentities) from Trello.
     */
    Delete(): void;
}

interface Board extends Entity {
    Description: string;
    Public: boolean;
    Closed: boolean;
}

interface TrelloBoardConstructor {
    /**
     *  @constructor @yields Creates a new Trello board, that is then also created on Trello.
     *
     *  @param entity The entity the board will be assigned to.
     *  @param name The Board's name. Must to be a non-empty string with a maximum of 16384 characters.
     *  @param public Whether the new board should be public or not. If this field is not provided, the board will be private.
     *
     *  @returns A new TrelloBoard that was freshly created.
     */
    new (name: string, public: boolean, entity: Client): Board;

    /**
     *  @yields Fetches a TrelloBoard from Trello.
     *
     *  @param entity The entity the board will be assigned to.
     *  @param remoteId The board's ID.
     *
     *  @returns The Trello Board fetched. Undefined if the board doesn't exist.
     */
    fromRemote: (remoteId: string, entity: Client) => Board | undefined;

    /**
     *  @yields Fetches all the boards the provided entity has edit access to.
     *
     *  @param entity The entity where to fetch the boards from.
     *
     *  @returns An array containing zero or more trello boards.
     */
    fetchAllFrom: (entity: Client) => Array<Board>;
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

export { Client, Board, Label, LabelColor };
